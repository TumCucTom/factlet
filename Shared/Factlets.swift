//
//  Factlets.swift
//  Factlet
//
//  Data model and collection of general knowledge factlets
//

import Foundation

struct Factlet: Codable, Identifiable, Equatable {
    let id: UUID
    let fact: String
    let category: String
    
    init(id: UUID = UUID(), fact: String, category: String) {
        self.id = id
        self.fact = fact
        self.category = category
    }
}

// MARK: - Factlet Collection
struct FactletCollection {
    static let all: [Factlet] = [
        // Science
        Factlet(fact: "Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs that was still perfectly edible.", category: "Science"),
        Factlet(fact: "A day on Venus is longer than its year. Venus takes 243 Earth days to rotate once, but only 225 Earth days to orbit the Sun.", category: "Science"),
        Factlet(fact: "Octopuses have three hearts and blue blood. Two hearts pump blood to the gills, while the third pumps it to the rest of the body.", category: "Science"),
        Factlet(fact: "Water can boil and freeze at the same time. This phenomenon, called the triple point, occurs at a specific temperature and pressure.", category: "Science"),
        Factlet(fact: "A teaspoon of neutron star would weigh about 6 billion tons.", category: "Science"),
        Factlet(fact: "Bananas are berries, but strawberries are not. Botanically, berries are fruits produced from a single ovary.", category: "Science"),
        Factlet(fact: "Lightning strikes the Earth about 8 million times per day, or roughly 100 times per second.", category: "Science"),
        Factlet(fact: "Your body contains about 37.2 trillion cells, and you lose about 200 billion cells every day.", category: "Science"),
        
        // History
        Factlet(fact: "Cleopatra lived closer in time to the Moon landing than to the construction of the Great Pyramid.", category: "History"),
        Factlet(fact: "Oxford University is older than the Aztec Empire. Teaching began in Oxford in 1096, while the Aztec Empire was founded in 1428.", category: "History"),
        Factlet(fact: "The shortest war in history lasted 38 to 45 minutes between Britain and Zanzibar on August 27, 1896.", category: "History"),
        Factlet(fact: "Ancient Romans used crushed mouse brains as toothpaste.", category: "History"),
        Factlet(fact: "Woolly mammoths were still alive when the Great Pyramid of Giza was being built, around 2660 BCE.", category: "History"),
        Factlet(fact: "The Eiffel Tower was originally intended to be a temporary structure, built for the 1889 World's Fair.", category: "History"),
        Factlet(fact: "Vikings never wore horned helmets. This is a 19th-century myth popularized by costume designers.", category: "History"),
        Factlet(fact: "The first computer programmer was Ada Lovelace, who wrote algorithms for Charles Babbage's Analytical Engine in the 1840s.", category: "History"),
        
        // Nature
        Factlet(fact: "A group of flamingos is called a flamboyance.", category: "Nature"),
        Factlet(fact: "Trees can communicate with each other through an underground network of fungi, sometimes called the 'Wood Wide Web.'", category: "Nature"),
        Factlet(fact: "A single cloud can weigh more than 1 million pounds, but floats because the air beneath it is even heavier.", category: "Nature"),
        Factlet(fact: "Cows have best friends and experience stress when separated from them.", category: "Nature"),
        Factlet(fact: "The Amazon rainforest produces about 20% of the world's oxygen.", category: "Nature"),
        Factlet(fact: "A jellyfish is 95% water. If washed ashore, it would nearly disappear as the water evaporates.", category: "Nature"),
        Factlet(fact: "Sloths can hold their breath longer than dolphins—up to 40 minutes by slowing their heart rate.", category: "Nature"),
        Factlet(fact: "The oldest known living tree is a bristlecone pine named Methuselah, which is over 4,850 years old.", category: "Nature"),
        
        // Language & Culture
        Factlet(fact: "'Dreamt' is the only English word that ends with the letters 'mt.'", category: "Language"),
        Factlet(fact: "There are more possible iterations of a game of chess than there are atoms in the observable universe.", category: "Culture"),
        Factlet(fact: "The sentence 'The quick brown fox jumps over the lazy dog' uses every letter of the alphabet.", category: "Language"),
        Factlet(fact: "Japan has more than 50,000 people who are over 100 years old.", category: "Culture"),
        Factlet(fact: "'Bookkeeper' is the only English word with three consecutive double letters.", category: "Language"),
        Factlet(fact: "The dot over the letters 'i' and 'j' is called a tittle.", category: "Language"),
        Factlet(fact: "A 'jiffy' is an actual unit of time: 1/100th of a second.", category: "Language"),
        Factlet(fact: "The shortest complete sentence in English is 'I am.'", category: "Language"),
        
        // Human Body
        Factlet(fact: "Your nose can remember 50,000 different scents.", category: "Human Body"),
        Factlet(fact: "The human brain uses about 20% of the body's total energy, despite being only 2% of its weight.", category: "Human Body"),
        Factlet(fact: "You are taller in the morning than in the evening due to spinal compression throughout the day.", category: "Human Body"),
        Factlet(fact: "Humans share about 60% of their DNA with bananas.", category: "Human Body"),
        Factlet(fact: "Your stomach gets a new lining every 3-4 days to prevent it from digesting itself.", category: "Human Body"),
        Factlet(fact: "The human eye can distinguish about 10 million different colors.", category: "Human Body"),
        Factlet(fact: "Fingernails grow nearly 4 times faster than toenails.", category: "Human Body"),
        Factlet(fact: "The strongest muscle in the human body, relative to its size, is the masseter (jaw muscle).", category: "Human Body"),
        
        // Geography
        Factlet(fact: "Russia has 11 time zones, more than any other country.", category: "Geography"),
        Factlet(fact: "Canada has more lakes than the rest of the world combined.", category: "Geography"),
        Factlet(fact: "Mount Everest grows about 4 millimeters every year due to tectonic activity.", category: "Geography"),
        Factlet(fact: "The Dead Sea is so salty that nothing can live in it, and you float effortlessly on its surface.", category: "Geography"),
        Factlet(fact: "Antarctica is the only continent without a time zone.", category: "Geography"),
        Factlet(fact: "The Pacific Ocean is larger than all the land on Earth combined.", category: "Geography"),
        Factlet(fact: "There is a town in Norway called Hell, and it freezes over every winter.", category: "Geography"),
        Factlet(fact: "The Sahara Desert is expanding by about 30 miles per year.", category: "Geography"),
        
        // Technology
        Factlet(fact: "The first ever website is still online at info.cern.ch.", category: "Technology"),
        Factlet(fact: "The average smartphone has more computing power than all of NASA in 1969.", category: "Technology"),
        Factlet(fact: "Email is older than the World Wide Web. The first email was sent in 1971, while the web was invented in 1989.", category: "Technology"),
        Factlet(fact: "The first computer mouse was made of wood.", category: "Technology"),
        Factlet(fact: "About 90% of the world's currency exists only digitally.", category: "Technology"),
        Factlet(fact: "The QWERTY keyboard was designed to slow down typing to prevent typewriter jams.", category: "Technology"),
        Factlet(fact: "The first 1GB hard drive, introduced in 1980, weighed over 500 pounds and cost $40,000.", category: "Technology"),
        Factlet(fact: "More people in the world have access to mobile phones than to toilets.", category: "Technology"),
    ]
    
    static func random() -> Factlet {
        all.randomElement() ?? all[0]
    }
    
    static func randomExcluding(_ current: Factlet?) -> Factlet {
        guard let current = current, all.count > 1 else {
            return random()
        }
        var newFactlet = random()
        while newFactlet.id == current.id {
            newFactlet = random()
        }
        return newFactlet
    }
}

