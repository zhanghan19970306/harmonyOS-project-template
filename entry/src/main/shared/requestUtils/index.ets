import { promptAction } from "@kit.ArkUI"
import { AxiosError, HttpStatusCode, InternalAxiosRequestConfig } from "@ohos/axios"
import { KvUtil, MD5 } from "@pura/harmony-utils"
import { BW_REQUEST_URL_PREFIX, DEBUG } from "BuildProfile"
import { CustomAxios } from "./extends"
import { isRes } from "./helper"
import { CacheItem, CustomAxiosResponse, Res } from "./model"

export type { SimpleError } from "./model"

export const request = new CustomAxios({
  baseURL: BW_REQUEST_URL_PREFIX,
  timeout: 30 * 1000,
  headers: {
    "Qm-From-Type": "catering",
    "Qm-From": "h5",
    "Accept-Encoding": "gzip",
    "Content-Type": "application/json",
    "Referer": BW_REQUEST_URL_PREFIX
  },
  responseType: "object"
})

request.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  //
  // let result =
  //   await Promise.all([preferencesUtils.get("lang", ""), preferencesUtils.get("loginInfo", null)])
  //
  // if (DEBUG && !result[1]) {
  //   result[1] ??= {
  //     token: "vGRwIdTRDpn5vbfwaRtXY0NrPPIQCGqbvW74xQb9q_Tf4dEMaT-RmE3ml5jRH0dl"
  //   } as ESObject
  // }

  // config.headers.set("accept-language", result[0])
  //   .set("Qm-User-Token", result[1]?.token ?? "")
  //   .set("multi-store-id", "1127778")
  //   .set("store-id", BW_BRANDID)

  return config
}, (error: AxiosError) => Promise.reject(error))

request.interceptors.response.use(<T>(response: CustomAxiosResponse<Res<T>>) => {
  const res = typeof response.data === "string" ? JSON.parse(response.data) as Res<T> : response.data

  if (response.config.cacheTime) {
    let key = ""
    if (response.config.method?.toLowerCase() === "get") {
      key = `${response.config.url}_get_${MD5.digestSync(JSON.stringify(response.config.params ?? ""))}`
    } else if (response.config.method?.toLowerCase() === "post") {
      key = `${response.config.url}_post_${MD5.digestSync(JSON.stringify(response.config.data ?? ""))}`
    }
    const cacheItem: CacheItem<T> = { updateTime: Date.now(), value: res }
    KvUtil.put(key, JSON.stringify(cacheItem))
  }

  if (response.config.$returnRaw) {
    const rawRes: ESObject = { data: res }
    return rawRes as object as CustomAxiosResponse<Res<T>>
  }

  //
  if (response.config.url?.includes("goods/list/category-item")) {
    console.log("goods/list/category-item =>", JSON.stringify(res.trace_id, null, 2))
  }

  if (!isRes(res)) {
    if (DEBUG) {
      console.error(`❌ 业务响应结构错误，错误信息如下\n请求url：${response.config.url}\n${JSON.stringify(res, null, 2)}`)
    }
    if (!response.config.skipErrorToast) {
      promptAction.showToast({ message: "请求异常" })
    }
    return Promise.reject(null)
  }

  if (!res.status) {
    if (DEBUG) {
      console.error(`❌ 业务响应错误，错误信息如下\n请求url：${response.config.url}\n请求参数：\n${JSON.stringify(response.config.params ||
      response.config.data, null, 2)}\n响应结果：\n${JSON.stringify(res, null, 2)}`)
    }
    if (!response.config.skipErrorToast) {
      promptAction.showToast({ message: res.message || "请求异常" })
    }

    return Promise.reject(res)
  }

  if (DEBUG) {
    console.info(`✅ 请求接口url ==>: ${response.config.url}成功，响应如下\n`, JSON.stringify(res, null, 2))
  }

  return res as object as CustomAxiosResponse<Res<T>>
}, (error: AxiosError) => {

  // 异常：http响应状态码非200
  if (error.response?.status !== HttpStatusCode.Ok) {
    promptAction.showToast({ message: "请求异常" })
    console.error(`❌ 响应http状态：${error.response?.statusText}`)
  }

  return Promise.reject(error)
})



