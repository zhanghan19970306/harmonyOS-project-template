import { Axios } from "@ohos/axios"
import { KvUtil, MD5 } from "@pura/harmony-utils"
import { DEBUG } from "BuildProfile"
import { CacheItem, CustomAxiosRequestConfig, CustomAxiosResponse } from "./model"

export class CustomAxios extends Axios {
  async $get<R = ESObject, D = ESObject>(url: string, config?: CustomAxiosRequestConfig<D>) {
    try {
      const key = `${url}_get_${MD5.digestSync(JSON.stringify(config?.params ?? ""))}`
      const cacheDataStr = await KvUtil.getString(key, "")
      if (cacheDataStr) {
        const cacheData: CacheItem<R> = JSON.parse(cacheDataStr)
        const cacheTime = config?.cacheTime ?? 0
        if (Date.now() - cacheData.updateTime < cacheTime) {
          DEBUG && console.log(`🎯【${url}】【get】命中缓存`)
          if (config?.$returnRaw) {
            return cacheData.value
          }
          return cacheData.value.data
        } else {
          KvUtil.delete(key)
        }
      }
    } catch (e) {
      console.log(e)
    }

    return super.get(url, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  async $post<R = ESObject, D = ESObject>(url: string, data: D, config?: CustomAxiosRequestConfig<D>) {
    try {
      const key = `${url}_post_${MD5.digestSync(JSON.stringify(data ?? ""))}`
      const cacheDataStr = await KvUtil.getString(key, "")
      if (cacheDataStr) {
        const cacheData: CacheItem<R> = JSON.parse(cacheDataStr)
        const cacheTime = config?.cacheTime ?? 0
        if (Date.now() - cacheData.updateTime < cacheTime) {
          DEBUG && console.log(`🎯【${url}】【post】命中缓存`)
          if (config?.$returnRaw) {
            return cacheData.value
          }
          return cacheData.value.data
        } else {
          KvUtil.delete(key)
        }
      }
    } catch (e) {
      console.log(e)
    }
    return super.post(url, data, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $delete<R = ESObject, D = ESObject>(url: string, config?: CustomAxiosRequestConfig<D>) {
    return super.delete(url, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $put<R = ESObject, D = ESObject>(url: string, data: D, config?: CustomAxiosRequestConfig<D>) {
    return super.put(url, data, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $options<R = ESObject, D = ESObject>(url: string, config?: CustomAxiosRequestConfig<D>) {
    return super.options(url, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $postForm<R = ESObject, D = ESObject>(url: string, data: D, config?: CustomAxiosRequestConfig<D>) {
    return super.postForm(url, data, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $putForm<R = ESObject, D = ESObject>(url: string, data: D, config?: CustomAxiosRequestConfig<D>) {
    return super.putForm(url, data, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }

  $patchForm<R = ESObject, D = ESObject>(url: string, data: D, config?: CustomAxiosRequestConfig<D>) {
    return super.patchForm(url, data, config)
      .then((res: CustomAxiosResponse<R, D>) => res.data)
  }
}



