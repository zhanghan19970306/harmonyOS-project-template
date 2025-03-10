export class CalcUtils {
  // 加法
  add(a: number, b: number): number {
    const precision = this.getPrecision(a, b);
    const factor = Math.pow(10, precision);
    return (this.toFixedNumber(a, precision) + this.toFixedNumber(b, precision)) / factor;
  }

  // 减法
  sub(a: number, b: number): number {
    const precision = this.getPrecision(a, b);
    const factor = Math.pow(10, precision);
    return (this.toFixedNumber(a, precision) - this.toFixedNumber(b, precision)) / factor;
  }

  // 乘法
  mul(a: number, b: number): number {
    const precisionA = this.getPrecision(a);
    const precisionB = this.getPrecision(b);
    const totalPrecision = precisionA + precisionB;
    return (
      (this.toFixedNumber(a, precisionA) * this.toFixedNumber(b, precisionB)) /
      Math.pow(10, totalPrecision)
    );
  }

  // 除法
  div(a: number, b: number): number {
    if (b === 0) {
      throw new Error("Division by zero is not allowed.");
    }
    const precisionA = this.getPrecision(a);
    const precisionB = this.getPrecision(b);
    const factorA = Math.pow(10, precisionA);
    const factorB = Math.pow(10, precisionB);
    return (
      (this.toFixedNumber(a, precisionA) / this.toFixedNumber(b, precisionB)) *
        (factorB / factorA)
    );
  }

  // 精度处理函数
  private toFixedNumber(num: number, precision: number): number {
    return Math.round(num * Math.pow(10, precision));
  }

  // 通用计算工具
  private getPrecision(...numbers: number[]): number {
    return Math.max(...numbers.map(num => {
      const decimalPart = num.toString().split(".")[1];
      return decimalPart ? decimalPart.length : 0;
    }));
  }
}