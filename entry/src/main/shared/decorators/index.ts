import _, { debounce, throttle } from "lodash"

// 节流
export function Throttle(wait: number, options?: _.ThrottleSettings) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value

    // 使用 lodash 的 throttle 包装原始方法
    descriptor.value = throttle(originalMethod, wait, options)

    return descriptor
  }
}

// 防抖
export function Debounce(wait: number, options?: _.DebounceSettings) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value

    // 使用 lodash 的 throttle 包装原始方法
    descriptor.value = debounce(originalMethod, wait, options)

    return descriptor
  }
}


