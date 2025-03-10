import { FormatText } from "./model"

export class FormatUtils {
  /**
   * 格式化手机号
   * */
  mobile(tel: unknown, format: FormatText = "$1****$3"): string {
    if (!tel || Number.isNaN(tel)) {
      return ""
    }
    const telStr = String(tel).trim()
    const isPlainMobile = /^\d{11}$/.test(telStr)
    return isPlainMobile ? telStr.replace(/(\d{3})(\d{4})(\d{4})/, format) : telStr
  }

  /**
   * 格式化金额
   *
   * @example 123 -> 123.00
   * @example 123.1 -> 123.10
   * @example 123.12 -> 123.12
   * @example 1234.12 -> 1,234.12
   * @example "000123" -> 123.00
   * @example "0" -> 0
   * @example "abc" -> "--"
   * */
  money(num: string | number, defaultValue: "--"): string {
    // 将输入转为字符串，并移除前导零
    const strNum = String(num).replace(/^0+(?=\d)/, "") // 移除非小数前导零

    // 检查是否为有效数字
    if (!/^-?\d+(\.\d+)?$/.test(strNum)) {
      return defaultValue
    }

    // 使用正则格式化整数部分，确保小数部分保留两位小数
    const [integerPart, decimalPart = ""] = strNum.split(".")
    const formattedInt = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
    const formattedDecimal = decimalPart.padEnd(2, "0").slice(0, 2)

    return `${formattedInt}.${formattedDecimal}`
  }

  /** 移除所有空格 */
  removeSpace(str: string): string {
    return str.replace(/\s/g, "")
  }

  /** 格式化距离 */
  distance(m = 0, len = 1): string {
    return m / 1000 >= 1 ? `${(m / 1000).toFixed(len)}km` : `${m}m`
  }
}