import type { Res } from "./model"

export const isRes = <T>(val: unknown): val is Res<T> => {
  if (typeof val === 'object' && val !== null) {
    return 'code' in val && 'data' in val && 'message' in val
  }
  return false
}

