declare namespace Qm {
  export type AnyObject = Record<string, ESObject>

  export type GetItem<T extends any[]> = T[number]

  export type GetRecordValue<O extends Record<string, ESObject>, K extends keyof O> = O[K]

  export type Awaited<T> =
    T extends null | undefined ? T : // special case for `null | undefined` when not in `--strictNullChecks` mode
      T extends object & {
        then(onfulfilled: infer F, ...args: infer _): any
      } ? // `await` only unwraps object types with a callable `then`. Non-object types are not unwrapped
        F extends ((value: infer V,
          ...args: infer _) => any) ? // if the argument to `then` is callable, extracts the first argument
          Awaited<V> : // recursively unwrap the value
          never : // the argument to `then` was not callable
        T; // non-object or non-thenable

  export interface ArrayLike<T> {
    readonly length: number;

    readonly [n: number]: T;
  }

  /**
   * Make all properties in T optional
   */
  export type Partial<T> = {
    [P in keyof T]?: T[P];
  };

  /**
   * Make all properties in T required
   */
  export type Required<T> = {
    [P in keyof T]-?: T[P];
  };

  /**
   * Make all properties in T readonly
   */
  export type Readonly<T> = {
    readonly [P in keyof T]: T[P];
  };

  /**
   * From T, pick a set of properties whose keys are in the union K
   */
  export type Pick<T, K extends keyof T> = {
    [P in K]: T[P];
  };

  /**
   * Construct a type with a set of properties K of type T
   */
  export type Record<K extends keyof any, T> = {
    [P in K]: T;
  };

  /**
   * Exclude from T those types that are assignable to U
   */
  export type Exclude<T, U> = T extends U ? never : T;

  /**
   * Extract from T those types that are assignable to U
   */
  export type Extract<T, U> = T extends U ? T : never;

  /**
   * Construct a type with the properties of T except for those in type K.
   */
  export type Omit<T, K extends keyof any> = Pick<T, Exclude<keyof T, K>>;

  /**
   * Exclude null and undefined from T
   */
  export type NonNullable<T> = T & {};

  /**
   * Obtain the parameters of a function type in a tuple
   */
  export type Parameters<T extends (...args: any) => any> = T extends (...args: infer P) => any ? P : never;

  /**
   * Obtain the parameters of a constructor function type in a tuple
   */
  export type ConstructorParameters<T
  extends abstract new (...args: any) => any> = T extends abstract new (...args: infer P) => any ? P : never;

  /**
   * Obtain the return type of a function type
   */
  export type ReturnType<T extends (...args: any) => any> = T extends (...args: any) => infer R ? R : any;

  /**
   * Obtain the return type of a constructor function type
   */
  export type InstanceType<T
  extends abstract new (...args: any) => any> = T extends abstract new (...args: any) => infer R ? R : any;

  /**
   * Convert string literal type to uppercase
   */
  export type Uppercase<S extends string> = intrinsic;

  /**
   * Convert string literal type to lowercase
   */
  export type Lowercase<S extends string> = intrinsic;

  /**
   * Convert first character of string literal type to uppercase
   */
  export type Capitalize<S extends string> = intrinsic;

  /**
   * Convert first character of string literal type to lowercase
   */
  export type Uncapitalize<S extends string> = intrinsic;

  /**
   * Marker for contextual 'this' type
   */
  export interface ThisType<T> {}

}