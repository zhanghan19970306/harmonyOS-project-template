// @ts-noCheck
export class JSBridge {
  /** UA中的特定标识 */
  private UAKind: string;
  /** 超时时间 */
  private timeout: number;
  /** 环境信息 */
  private env: JSBridge.Env;
  /** 调用队列 */
  private callingQueue: Map<string, JSBridge.CallQueueHandler>;
  /** 监听队列 */
  private listenerQueue: JSBridge.Listener[] = [];
  /** native inject object name */
  private nativeInjectObjectName: string;
  /** native inject method name */
  private nativeInjectMethodName: string;
  /** 创建一个全局方法 等待Native调用 */
  private waitNativeCallMethodName: string;

  constructor(options: JSBridge.Options) {
    this.UAKind = options.UAKind;
    this.timeout = options.timeout ?? 30 * 1000;
    this.nativeInjectObjectName = options.nativeInjectObjectName ?? "native";
    this.nativeInjectMethodName =
      options.nativeInjectMethodsName ?? "callNative";
    this.waitNativeCallMethodName =
      options.waitNativeCallMethodName ?? "qmaiBridgeHandle";

    this.env = this.getEnv();
    if (!this.env.isApp) {
      console.warn("当前环境不在APP当中");
    }

    this.initHandler();
  }

  $emit(
    method: string,
    data: Record<string, any>,
    options: JSBridge.CallOptions
  ) {
    const { promise, reject, resolve } = Promise.withResolvers();

    // 生成传输对象
    const dto = { eventId: this.genNaoid(), method, data };

    // 将传输对象转为JSON字符串
    const dtoString = JSON.stringify(dto);

    // 生成倒计时
    let timerId = -9999;
    const timeout = Math.max(options.timeout ?? this.timeout ?? 0, 0);
    if (timeout !== 0) {
      timerId = window.setTimeout(
        () => reject({ code: 504, message: "请求超时", data: null }),
        timeout
      );
    }

    this.callingQueue.set(dto.eventId, {
      timerId,
      method,
      options,
      resolve,
      reject,
    });

    if (this.env.isIOS) {
      window.webkit.messageHandlers[this.nativeInjectMethodName].postMessage(
        dtoString
      );
    } else if (this.env.isAndroid) {
      window[this.nativeInjectObjectName][this.nativeInjectMethodName](
        dtoString
      );
    } else if (this.env.isHarmonyOS) {
      window[this.nativeInjectObjectName][this.nativeInjectMethodName](
        dtoString
      );
    } else {
      reject({ code: 500, message: "当前环境不在APP当中", data: null });
    }

    return promise;
  }

  $on<T>(method: string, callBack: (data: T) => void): string {
    const listenerId = this.genNaoid();
    this.listenerQueue.push({
      listenerId,
      method,
      callBack,
      path: window.location.pathname,
    });
    return listenerId;
  }

  $once<T>(method: string, callBack: (data: T) => void): string {
    const listenerId = this.genNaoid();
    this.listenerQueue.push({
      listenerId,
      method,
      callBack,
      path: window.location.pathname,
      only: true,
    });
    return listenerId;
  }

  $off(kind: string, type: "method" | "listenerId" = "listenerId") {
    this.listenerQueue = this.listenerQueue.filter(
      (item) => item[type] !== kind
    );
  }

  getEnv(): JSBridge.Env {
    const userAgent = navigator.userAgent.toLowerCase();
    return {
      isApp: userAgent.includes(this.UAKind),
      isIOS: /macintosh|mac os x|iphone|ipad|ipod|ios/i.test(userAgent),
      isAndroid: /android/i.test(userAgent),
      isHarmonyOS: /harmonyos/i.test(userAgent),
    };
  }

  /** 初始化handle */
  private initHandler() {
    Object.defineProperty(window, this.waitNativeCallMethodName, {
      value: (response: string) => {
        try {
          console.log("========== native返回的原始数据 start ===========");
          console.log(response);
          console.log("========== native返回的原始数据 end ===========");

          const res: JSBridge.Response = JSON.parse(response);

          // TODO: 为空认定为 是Native主动通信web
          if (res.eventId === "") {
            this.listenerQueue.forEach((listener) => {
              if (res.method === listener.method) {
                listener.callBack(res.data);
                if (listener.only) {
                  this.$off(listener.listenerId, "listenerId");
                }
              }
            });
          } else {
            const request = this.callingQueue.get(res.eventId);
            // 没有找到通信句柄
            if (!request) {
              throw new Error("执行队列中没有找到 web端发起的通信句柄");
            }
            // 分解出对象属性/方法
            const { timerId, resolve } = request;
            // 停止超时检测
            clearTimeout(timerId);
            // 返回数据
            resolve(res.data);
            // 删除通信句柄
            setTimeout(() => this.callingQueue.delete(res.eventId), 0);
          }
        } catch (error) {
        }
      },
      writable: false,
    });
  }

  /**
   * 生成唯一id
   */
  private genNaoid(size = 21) {
    const urlAlphabet =
      "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict";
    let id = "";
    let i = size;
    while (i--) {
      id += urlAlphabet[(Math.random() * 64) | 0];
    }
    return id;
  }
}

namespace JSBridge {
  export interface Options {
    /** user-agent中会包含一个特定字符来判断是否在 App的webview容器内 */
    UAKind: string;

    /** 超时时间 */
    timeout?: number;

    /** 原生注入下来的对象名称 */
    nativeInjectObjectName?: string;

    /** 原生注入下来的调用方法名称 */
    nativeInjectMethodsName?: string;

    /** H5注册的全局方法名称  */
    waitNativeCallMethodName?: string;
  }

  export interface Env {
    isApp: boolean;
    isIOS: boolean;
    isAndroid: boolean;
    isHarmonyOS: boolean;
  }

  export interface Request {
    eventId: string;
    method: string;
    data: Record<string, any> | null;
  }

  export interface Response {
    eventId: string;
    method: string;
    code: Number;
    message: string;
    data: Record<string, any> | null;
  }

  export interface CallOptions {
    /** 超时时间 */
    timeout?: Options["timeout"];
  }

  export interface CallQueueHandler {
    timerId: number;
    method: string;
    options: CallOptions;
    resolve: (resolve: any) => void;
    reject: (reject: any) => void;
  }

  export interface Listener {
    listenerId: string;
    method: string;
    path: string;

    /** 是否只监听一次 */
    only?: boolean;

    callBack(data: any): void;
  }
}
