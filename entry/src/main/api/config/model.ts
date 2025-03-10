export interface CountryEntity {
  id: number,
  name: string,
  name_en: string,
  name_tw: string,
  letter_code_two: string,
  letter_code_three: string,
  global_roaming: string,
  is_china: 0 | 1
}