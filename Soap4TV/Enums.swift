//
//  Genres.swift
//  Soap4TV
//
//  Created by Peter on 23/11/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import Foundation

enum Weekdays: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
	func day() -> String {
		switch self {
		case .Sunday:
			return "Воскресенье"
		case .Monday:
			return "Понедельник"
		case .Tuesday:
			return "Вторник"
		case .Wednesday:
			return "Среда"
		case .Thursday:
			return "Четверг"
		case .Friday:
			return "Пятница"
		case .Saturday:
			return "Суббота"
		}
	}
}


enum GenreType: String {
	
	case Action = "Action"
	case Animation = "Animation"
	case Comedy = "Comedy"
	case Documentary = "Documentary"
	case Family = "Family"
	case Food = "Food"
	case MiniSeries = "Mini-Series"
	case Romance = "Romance"
	case Soap = "Soap"
	case Sport = "Sport"
	case Travel = "Travel"
	case Adventure = "Adventure"
	case Children = "Children"
	case Crime = "Crime"
	case Drama = "Drama"
	case Fantasy = "Fantasy"
	case Horror = "Horror"
	case Mystery = "Mystery"
	case Reality = "Reality"
	case ScienceFiction = "Science-Fiction"
	case Suspense = "Suspense"
	case Thriller = "Thriller"
	case Western = "Western"
	
	func map(word: String) -> GenreType? {
		if self.rawValue == word {
			return self
		}
		return nil
	}
	
	func translate() -> String {
		switch self {
			case .Action:
				return "Боевик"
			case .Animation:
				return "Мульфильм"
			case .Adventure:
				return "Приключения"
			case .Comedy:
				return "Комедия"
			case .Documentary:
				return "Документальный"
			case .Family:
				return "Семейный"
			case .Food:
				return "О еде"
			case .MiniSeries:
				return "Мини-сериал"
			case .Romance:
				return "Романтика"
			case .Soap:
				return "Мыльная опера"
			case .Sport:
				return "Спорт"
			case .Travel:
				return "Путешествия"
			case .Crime:
				return "Детектив"
			case .Drama:
				return "Драма"
			case .Fantasy:
				return "Фэнтези"
			case .Horror:
				return "Ужасы"
			case .Mystery:
				return "Мистика"
			case .Reality:
				return "Реалити шоу"
			case .ScienceFiction:
				return "Фантастика"
			case .Suspense:
				return "Саспенс"
			case .Thriller:
				return "Триллер"
			case .Western:
				return "Вестерн"
			default:
				return ""
		}
	}

}