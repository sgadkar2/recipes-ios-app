//
//  ContentView.swift
//  Recipes-App
//
//  Created by Samsher Gadkary on 1/23/24.
//

import SwiftUI

struct Ingredient: Hashable {
    let name: String
    let measure: String
}

struct Meals: Decodable {
    let meals: [Meal]
}

struct Meal: Decodable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
    let strInstructions: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
}

func fetchMealListFromAPI(completion: @escaping ([Meal]?, Error?) -> Void) {
    let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!

    URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(Meals.self, from: data)
                completion(decoded.meals, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
}

func fetchRecipeFromAPI(mealId: String, completion: @escaping ([Meal]?, Error?) -> Void) {
    let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)")!

    URLSession.shared.dataTask(with: url) { data, response, error in
        
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }

            do {
                let decoded = try JSONDecoder().decode(Meals.self, from: data)
                completion(decoded.meals, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
}



struct ContentView: View {
    
    @State private var meals: [Meal] = []
    
    @State private var isDarkMode = false
        
    var body: some View {
        
        NavigationView {
            List(meals.sorted(by: { $0.strMeal < $1.strMeal }), id: \.idMeal){ meal in
                    ScrollView{
                        VStack(alignment: .leading) {
                            NavigationLink(destination: RecipeView(mealId: meal.idMeal, isDarkMode: $isDarkMode)){
                                AsyncImage(url: URL(string: meal.strMealThumb)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            case .failure:
                                                Image(systemName: "photo")
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                .frame(width: .infinity, height: 200)
                            }
                            
                        }
                        
                    }
                

            }
            .onAppear {
                    fetchMealListFromAPI { result, error in
                            if let result = result {
                                meals = result
                            }else if let error = error {
                                print("Error ferching data: \(error.localizedDescription)")
                            }
                        }
                    }
        }
    }
    
}

struct RecipeView: View {
    
    let mealId: String
    
    @State private var meals: [Meal] = []
        
    @Binding var isDarkMode: Bool
    
    var body: some View {
        
        VStack {
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            
            List(meals, id: \.idMeal){ meal in
                ScrollView{
                    VStack {
                        Text(meal.strMeal)
                            .font(.system(size: 40))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("Instructions")
                            .font(.system(size: 30))
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(meal.strInstructions ?? "Instructions not available")
                            .font(.body)
                            .foregroundColor(isDarkMode ? Color.white : Color.black)
                        
                        Text("Ingredients")
                            .font(.system(size: 30))
                            .font(.headline)
                            .foregroundColor(.blue)
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 1), spacing: 2) {
                            
                            
                            let filteredIngredients:  [Ingredient] = (1..<21).compactMap { number in
                                guard let ingredient = getProperty(meal, key: "strIngredient\(number)") as? String,
                                      let measure = getProperty(meal, key: "strMeasure\(number)") as? String,
                                      !ingredient.isEmpty, !measure.isEmpty else {
                                    return nil
                                }

                                return Ingredient(name: ingredient, measure: measure)
                            }
                            ForEach(filteredIngredients, id: \.self) { ingredient in
                                    HStack {
                                        Text(ingredient.name)
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        Text(ingredient.measure)
                                            .font(.body)
                                            .foregroundColor(isDarkMode ? Color.white : Color.black)
                                    }
                                    .padding()
                                    .background(isDarkMode ? Color.black : Color.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                }.preferredColorScheme(isDarkMode ? .dark : .light)
            }
            .onAppear {
                fetchRecipeFromAPI(mealId: mealId) { result, error in
                    if let result = result {
                        meals = result
                    }else if let error = error {
                        print("Error ferching data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

func getProperty<T>(_ instance: T, key: String) -> Any? {
    let mirror = Mirror(reflecting: instance)
    for child in mirror.children {
        if let label = child.label, label == key {
            return child.value
        }
    }
    return nil
}

#Preview {
    ContentView()
}



