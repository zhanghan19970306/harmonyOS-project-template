import { webview } from "@kit.ArkWeb"

export class QmBridge {
  webviewController: webview.WebviewController

  constructor(webviewController: webview.WebviewController) {
    this.webviewController = webviewController
  }

  callNative(paramsStr: string) {
    const params: QmBridge.Request = JSON.parse(paramsStr)

    switch (params.method) {
      case "uploadImage":
        break
      default:
        break
    }
  }

  private returnSuccessRes(params: QmBridge.Request, data: ESObject) {
    const result: QmBridge.Response = {
      eventId: params.eventId,
      method: params.method,
      code: 0,
      message: "请求成功",
      data
    }
    this.webviewController.runJavaScript(`qmaiBridgeHandle('${JSON.stringify(result)}')`)
  }

  private returnRes(result: QmBridge.Response) {
    this.webviewController.runJavaScript(`qmaiBridgeHandle('${JSON.stringify(result)}')`)
  }

}

namespace QmBridge {

  export interface Request<T = Record<string, ESObject> | null> {
    eventId: string;
    method: string;
    data: T;
  }

  export interface Response {
    eventId: string;
    method: string;
    code: Number;
    message: string;
    data: Record<string, ESObject> | null;
  }

  export interface PreloadDataDTO {
    kind: "commonInfo" | "ext" | "login"
  }
}