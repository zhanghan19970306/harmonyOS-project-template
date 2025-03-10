import { util } from "@kit.ArkTS"
import { isPlainObject } from "lodash"
import { DebugOptions } from "./model"

export const proxyAopFn: (arg: any) => void = (PreferencesUtils: any) => {

  const methods = ['set', 'delete', 'get', "has"] as const
  const hasReturnMethods = new Set(['get', "has"])

  methods.forEach(method => {
    util.Aspect.addAfter(PreferencesUtils, method, false,
      async (instance: any, result: any, key: string, defaultValue: any, debugOptions?: DebugOptions) => {

        try {
          const realResult = await result
          if (hasReturnMethods.has(method) || realResult === true) {
            const showRealResult = isPlainObject(realResult) ? JSON.stringify(realResult) : realResult

            // Tip: 并不是所有的访问都需要去打印日志
            if (method !== "get" || method === "get" && debugOptions?.showProxyPrint !== false) {
              console.log(`✅ preferences[${instance.name}] ${method}【${key}】success, reuslt is【${showRealResult}】`)
            }
          } else {
            console.error(`❌ preferences[${instance.name}] ${method}【${key}】fail`)
          }
        } catch (e) {
          console.error(`❌ preferences[${instance.name}] ${method} ${key}】fail`)
        } finally {
          return result
        }
      })
  })
}