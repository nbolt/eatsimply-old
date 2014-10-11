unless Course.first
Course.create!([
  {name: "Main Dishes", yummly_attr: "course^course-Main Dishes"},
  {name: "Desserts", yummly_attr: "course^course-Desserts"},
  {name: "Side Dishes", yummly_attr: "course^course-Side Dishes"},
  {name: "Lunch and Snacks", yummly_attr: "course^course-Lunch and Snacks"},
  {name: "Appetizers", yummly_attr: "course^course-Appetizers"},
  {name: "Salads", yummly_attr: "course^course-Salads"},
  {name: "Breakfast and Brunch", yummly_attr: "course^course-Breakfast and Brunch"},
  {name: "Breads", yummly_attr: "course^course-Breads"},
  {name: "Soups", yummly_attr: "course^course-Soups"},
  {name: "Beverages", yummly_attr: "course^course-Beverages"},
  {name: "Condiments and Sauces", yummly_attr: "course^course-Condiments and Sauces"},
  {name: "Cocktails", yummly_attr: "course^course-Cocktails"}
])
end
unless Cuisine.first
Cuisine.create!([
  {name: "American", yummly_attr: "cuisine^cuisine-american"},
  {name: "Italian", yummly_attr: "cuisine^cuisine-italian"},
  {name: "Asian", yummly_attr: "cuisine^cuisine-asian"},
  {name: "Mexican", yummly_attr: "cuisine^cuisine-mexican"},
  {name: "Southern & Soul Food", yummly_attr: "cuisine^cuisine-southern"},
  {name: "French", yummly_attr: "cuisine^cuisine-french"},
  {name: "Southwestern", yummly_attr: "cuisine^cuisine-southwestern"},
  {name: "Barbecue", yummly_attr: "cuisine^cuisine-barbecue-bbq"},
  {name: "Indian", yummly_attr: "cuisine^cuisine-indian"},
  {name: "Chinese", yummly_attr: "cuisine^cuisine-chinese"},
  {name: "Cajun & Creole", yummly_attr: "cuisine^cuisine-cajun"},
  {name: "Mediterranean", yummly_attr: "cuisine^cuisine-mediterranean"},
  {name: "Greek", yummly_attr: "cuisine^cuisine-greek"},
  {name: "English", yummly_attr: "cuisine^cuisine-english"},
  {name: "Spanish", yummly_attr: "cuisine^cuisine-spanish"},
  {name: "Thai", yummly_attr: "cuisine^cuisine-thai"},
  {name: "German", yummly_attr: "cuisine^cuisine-german"},
  {name: "Moroccan", yummly_attr: "cuisine^cuisine-moroccan"},
  {name: "Irish", yummly_attr: "cuisine^cuisine-irish"},
  {name: "Japanese", yummly_attr: "cuisine^cuisine-japanese"},
  {name: "Cuban", yummly_attr: "cuisine^cuisine-cuban"},
  {name: "Hawaiian", yummly_attr: "cuisine^cuisine-hawaiian"},
  {name: "Swedish", yummly_attr: "cuisine^cuisine-swedish"},
  {name: "Portuguese", yummly_attr: "cuisine^cuisine-portuguese"},
  {name: "Hungarian", yummly_attr: "cuisine^cuisine-hungarian"}
])
end
unless Diet.first
Diet.create!([
  {name: "Vegan", yummly_attr: "386^Vegan"},
  {name: "Lacto vegetarian", yummly_attr: "388^Lacto vegetarian"},
  {name: "Ovo vegetarian", yummly_attr: "389^Ovo vegetarian"},
  {name: "Pescetarian", yummly_attr: "390^Pescetarian"},
  {name: "Vegetarian", yummly_attr: "387^Lacto-ovo vegetarian"}
])
end
unless Nutrient.first
Nutrient.create!([
  {name: "Calcium", minimize: false, prime: true, daily_value: 1000, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: "nf_calcium_dv", yummly_supported: true, nutri_supported: nil, attr: "CA"},
  {name: "Potassium", minimize: false, prime: true, daily_value: 3500, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: true, nutri_supported: nil, attr: "K"},
  {name: "Iron", minimize: false, prime: true, daily_value: 18, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: "nf_iron_dv", yummly_supported: true, nutri_supported: nil, attr: "FE"},
  {name: "Calories", minimize: false, prime: true, daily_value: 2000, dv_unit: 'kcal', group: nil, yummly_unit: "kcal", yummly_field: "nf_calories", yummly_supported: true, nutri_supported: nil, attr: "ENERC_KCAL"},
  {name: "Fat", minimize: true, daily_value: 65, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_total_fat", yummly_supported: true, nutri_supported: nil, attr: "FAT"},
  {name: "Trans Fat", minimize: true, group: nil, dv_unit:'g', yummly_unit: "gram", yummly_field: "nf_trans_fatty_acid", yummly_supported: true, nutri_supported: nil, attr: "FATRN"},
  {name: "Cholesterol", minimize: true, daily_value: 300, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: "nf_cholesterol", yummly_supported: true, nutri_supported: nil, attr: "CHOLE"},
  {name: "Sodium", minimize: true, daily_value: 2400, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: "nf_sodium", yummly_supported: true, nutri_supported: nil, attr: "NA"},
  {name: "Carbohydrates", minimize: false, prime: true, daily_value: 300, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_total_carbohydrate", yummly_supported: true, nutri_supported: nil, attr: "CHOCDF"},
  {name: "Fiber", minimize: false, prime: true, daily_value: 25, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_dietary_fiber", yummly_supported: true, nutri_supported: nil, attr: "FIBTG"},
  {name: "Sugars", minimize: true, daily_value: 90, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_sugars", yummly_supported: true, nutri_supported: nil, attr: "SUGAR"},
  {name: "Vitamin A", minimize: false, daily_value: 5000, dv_unit: 'IU', unitwise_method: 'international_unit', group: nil, yummly_unit: "IU", yummly_field: "nf_vitamin_a_dv", yummly_supported: true, nutri_supported: nil, attr: "VITA_IU"},
  {name: "Protein", minimize: false, prime: true, daily_value: 50, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_protein", yummly_supported: true, nutri_supported: nil, attr: "PROCNT"},
  {name: "Vitamin C", minimize: false, daily_value: 60, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: "nf_vitamin_c_dv", yummly_supported: true, nutri_supported: nil, attr: "VITC"},
  {name: "Manganese", minimize: false, daily_value: 2, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "MN"},
  {name: "Folate", minimize: false, daily_value: 400, dv_unit: 'mcg', unitwise_method: 'microgram', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "FOL"},
  {name: "Niacin", minimize: false, daily_value: 20, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "NIA"},
  {name: "Selenium", minimize: false, daily_value: 70, dv_unit: 'mcg', unitwise_method: 'microgram', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "SE"},
  {name: "Zinc", minimize: false, daily_value: 15, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "ZN"},
  {name: "Starch", minimize: false, group: nil, dv:unit: 'g', yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "STARCH"},
  {name: "Saturated Fat", minimize: true, daily_value: 20, dv_unit: 'g', group: nil, yummly_unit: "gram", yummly_field: "nf_saturated_fat", yummly_supported: true, nutri_supported: nil, attr: "FASAT"},
  {name: "Thiamin", minimize: false, daily_value: 1.5, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "THIA"},
  {name: "Vitamin B6", minimize: false, daily_value: 2, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "VITB6A"},
  {name: "Iodine", minimize: false, daily_value: 150, dv_unit: 'mcg', unitwise_method: 'microgram', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: nil},
  {name: "Riboflavin", minimize: false, daily_value: 1.7, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "RIBF"},
  {name: "Pantothenic Acid", minimize: false, daily_value: 10, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "PANTAC"},
  {name: "Phosphorus", minimize: false, daily_value: 1000, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "P"},
  {name: "Vitamin B12", minimize: false, daily_value: 6, dv_unit: 'mcg', unitwise_method: 'microgram', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: nil},
  {name: "Copper", minimize: false, daily_value: 2, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "CU"},
  {name: "Vitamin E", minimize: false, daily_value: 20, dv_unit: 'mg', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: "TOCPHA"},
  {name: "Vitamin K", minimize: false, daily_value: 80, dv_unit: 'mcg', unitwise_method: 'microgram', group: nil, yummly_unit: "gram", yummly_field: nil, yummly_supported: nil, nutri_supported: nil, attr: nil}
])
end
unless Settings.first
Settings.create!([
  {recipe_cache: nil, cache_recipe: false}
])
end
unless Unit.first
Unit.create!([
  {name: "teaspoon", abbr: "tsp.", generic: true, abbr_no_period: "tsp"},
  {name: "drop", abbr: nil, generic: true, abbr_no_period: nil},
  {name: "tablespoon", abbr: "tbsp.", generic: true, abbr_no_period: "tbsp"},
  {name: "ounce", abbr: "oz.", generic: true, abbr_no_period: "oz"},
  {name: "cup", abbr: "C", generic: true, abbr_no_period: "C"},
  {name: "pint", abbr: "pt.", generic: true, abbr_no_period: "pt"},
  {name: "quart", abbr: "qt.", generic: nil, abbr_no_period: "qt"},
  {name: "gallon", abbr: "gal.", generic: nil, abbr_no_period: "gal"},
  {name: "liter", abbr: "L", generic: nil, abbr_no_period: "L"},
  {name: "pound", abbr: "lb.", generic: true, abbr_no_period: "lb"},
  {name: "milligram", abbr: "mg.", generic: true, abbr_no_period: "mg"},
  {name: "microgram", abbr: "mcg.", generic: true, abbr_no_period: "mcg"},
  {name: "gram", abbr: "g.", generic: true, abbr_no_period: "g"},
  {name: "international unit", abbr: "IU", generic: true, abbr_no_period: "IU"},
  {name: "kilocalorie", abbr: "kcal.", generic: true, abbr_no_period: "kcal"}
])
end
