import { http } from "@kit.NetworkKit";
import {
  AxiosRequestConfig,
  AxiosRequestHeaders,
  AxiosResponseHeaders,
  RawAxiosResponseHeaders
} from "@ohos/axios";

export interface CustomAxiosRequestConfig<T> extends AxiosRequestConfig {
  /** 是否跳过错误toast */
  skipErrorToast?: boolean
  /** 响应错误时是否需要返回原始错误信息 */
  returnErrorResponse?: boolean
  /** 是否返回原始数据 */
  $returnRaw?: boolean
  /** 缓存时间 单位: 毫秒 */
  cacheTime?: number
}

interface CustomInternalAxiosRequestConfig<D = any> extends CustomAxiosRequestConfig<D> {
  headers: AxiosRequestHeaders;
}

export interface CustomAxiosResponse<T = any, D = any> {
  data: T;
  status: number;
  statusText: string;
  headers: RawAxiosResponseHeaders | AxiosResponseHeaders;
  config: CustomInternalAxiosRequestConfig<D>;
  request?: any;
  performanceTiming?: http.PerformanceTiming;
}

export interface Res<T> {
  code: string
  data: T
  message: string
  status: boolean
  trace_id: string
}

export type SimpleError = {
  code: Res<object>['code']
  data: null
  message: Res<object>['message']
}

export interface CacheItem<T> {
  updateTime: number
  value: Res<T>
}