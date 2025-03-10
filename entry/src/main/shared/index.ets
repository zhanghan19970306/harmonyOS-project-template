export * from "./helper"

export * from "./JsBridge"

export * from "./colorUtils"

export * from "./calcUtils"

export * from "./decorators"

export * from "./validateUtils"

export * from "./eventHubUtils"

export * from "./deviceUtils"

export * from "./formatUtils"

export * from "./locationUtils"

export * from "./preferencesUtils"

/**
 * 休眠函数
 *
 * @param time
 * @returns
 */
export function sleep(time = 300): Promise<never> {
  return new Promise((resolve) => setTimeout(resolve, time))
}