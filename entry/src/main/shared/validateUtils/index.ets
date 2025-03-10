import { isNull, isUndefined } from "lodash"

export class ValidateUtils {
  /**
   * 是否为手机号
   */
  isMobile(value: string | number): boolean {
    if (isNull(value) || isUndefined(value) || Number.isNaN(value)) {
      return false
    }
    const str = String(value)
      .replace(/[^-|\d]/g, "")
    return /^((\+86)|(86))?(1)\d{10}$/.test(str) || /^0[0-9-]{10,13}$/.test(str)
  }

  /**
   * 是否全为中文
   * */
  isAllChinese(str: string): boolean {
    return /^[\u4e00-\u9fa5\u3400-\u4DBF\u20000-\u2A6DF\u2A700-\u2B73F\u2B740-\u2B81F\u2B820-\u2CEAF\uF900-\uFAFF]+$/.test(str)
  }
}












