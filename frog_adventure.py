#!/usr/bin/env python3

import random
import json
import os
from typing import Dict, List, Optional
from dataclasses import dataclass
from enum import Enum
from openai import OpenAI
from pydantic import BaseModel

class FrogType(Enum):
    TREE_FROG = "Tree Frog"
    POISON_DART_FROG = "Poison Dart Frog"
    BULLFROG = "Bullfrog"
    GLASS_FROG = "Glass Frog"
    ROCKET_FROG = "Rocket Frog"
    RAIN_FROG = "Rain Frog"
    CUSTOM = "Custom"

class GeneratedFrog(BaseModel):
    name: str
    species: str
    appearance: str
    personality: str
    special_ability: str
    ability_description: str
    favorite_food: str
    unique_trait: str
    backstory: str

@dataclass
class Frog:
    name: str
    frog_type: FrogType
    ability: str
    description: str
    energy: int = 100
    happiness: int = 50
    items: List[str] = None
    species: str = ""
    personality: str = ""
    backstory: str = ""
    
    def __post_init__(self):
        if self.items is None:
            self.items = []

class Adventure:
    def __init__(self):
        self.current_frog: Optional[Frog] = None
        self.save_file = "frog_adventure_save.json"
        self.adventures_completed = 0
        self.openai_client = None
        self.use_ai = False
        self._init_openai()
    
    def _init_openai(self):
        api_key = os.getenv("OPENAI_API_KEY")
        if api_key:
            try:
                self.openai_client = OpenAI(api_key=api_key)
                self.use_ai = True
                print("🤖 AI-powered frog generation enabled!")
            except Exception as e:
                print(f"⚠️  Could not initialize OpenAI: {e}")
                print("   Falling back to standard frog generation")
                self.use_ai = False
        else:
            print("💡 Set OPENAI_API_KEY environment variable for AI-generated frogs!")
    
    def generate_ai_frog(self) -> Optional[Frog]:
        if not self.use_ai or not self.openai_client:
            return None
        
        try:
            print("\n✨ Generating a unique frog companion...")
            
            completion = self.openai_client.beta.chat.completions.parse(
                model="gpt-4o-mini",
                messages=[
                    {
                        "role": "system",
                        "content": "You are a creative game designer creating unique frog characters for an adventure game."
                    },
                    {
                        "role": "user",
                        "content": """Create a unique frog character for an adventure game. Be creative and whimsical!
                        The frog should have:
                        - A memorable name (not generic like 'Hoppy')
                        - An interesting species (can be real or fantastical)
                        - Vivid appearance description
                        - Distinct personality traits
                        - A unique special ability that would help in adventures
                        - Detailed description of how their ability works
                        - Their favorite food (be creative!)
                        - One unique quirk or trait
                        - A brief, interesting backstory (2-3 sentences)"""
                    }
                ],
                response_format=GeneratedFrog,
            )
            
            generated = completion.choices[0].message.parsed
            
            return Frog(
                name=generated.name,
                frog_type=FrogType.CUSTOM,
                ability=generated.special_ability,
                description=f"{generated.appearance} {generated.personality}",
                species=generated.species,
                personality=generated.personality,
                backstory=generated.backstory
            )
            
        except Exception as e:
            print(f"❌ AI generation failed: {e}")
            return None
        
    def get_random_frog(self) -> Frog:
        ai_frog = self.generate_ai_frog()
        if ai_frog:
            return ai_frog
        
        frog_configs = {
            FrogType.TREE_FROG: {
                "ability": "Climb anywhere",
                "description": "A nimble green frog with sticky toe pads"
            },
            FrogType.POISON_DART_FROG: {
                "ability": "Intimidate predators",
                "description": "A brilliantly colored frog that warns danger away"
            },
            FrogType.BULLFROG: {
                "ability": "Powerful leap",
                "description": "A large, strong frog with a booming voice"
            },
            FrogType.GLASS_FROG: {
                "ability": "Near invisibility",
                "description": "A translucent frog that can hide in plain sight"
            },
            FrogType.ROCKET_FROG: {
                "ability": "Super speed",
                "description": "A tiny frog that moves like lightning"
            },
            FrogType.RAIN_FROG: {
                "ability": "Weather prediction",
                "description": "A round, grumpy-looking frog that senses storms"
            }
        }
        
        frog_type = random.choice(list(FrogType))
        config = frog_configs[frog_type]
        
        names = ["Ribbit", "Hopscotch", "Lily", "Splash", "Croak", "Puddle", 
                 "Bubbles", "Swampy", "Leaper", "Moss", "Dew", "Spring"]
        
        return Frog(
            name=random.choice(names),
            frog_type=frog_type,
            ability=config["ability"],
            description=config["description"]
        )
    
    def display_frog_status(self):
        if not self.current_frog:
            return
        
        if self.current_frog.frog_type == FrogType.CUSTOM:
            print(f"\n🐸 {self.current_frog.name} the {self.current_frog.species}")
        else:
            print(f"\n🐸 {self.current_frog.name} the {self.current_frog.frog_type.value}")
        
        print(f"   {self.current_frog.description}")
        print(f"   Special Ability: {self.current_frog.ability}")
        
        if self.current_frog.backstory:
            print(f"   Backstory: {self.current_frog.backstory}")
        
        print(f"   Energy: {'🟢' * (self.current_frog.energy // 20)}{'⚪' * (5 - self.current_frog.energy // 20)}")
        print(f"   Happiness: {'😊' if self.current_frog.happiness > 70 else '🙂' if self.current_frog.happiness > 30 else '😔'}")
        if self.current_frog.items:
            print(f"   Items: {', '.join(self.current_frog.items)}")
    
    def start_adventure(self):
        scenarios = [
            {
                "title": "The Mysterious Pond",
                "description": "You discover a shimmering pond deep in the forest. Strange lights dance beneath the surface.",
                "choices": {
                    "1": ("Dive in to investigate", self.pond_dive),
                    "2": ("Use your ability to explore safely", self.use_ability),
                    "3": ("Look for clues around the pond", self.investigate_area)
                }
            },
            {
                "title": "The Lost Tadpole",
                "description": "A tiny tadpole is crying - it's lost its family in the swift stream!",
                "choices": {
                    "1": ("Help search the stream", self.search_stream),
                    "2": ("Use your ability to help", self.use_ability),
                    "3": ("Comfort the tadpole first", self.comfort_tadpole)
                }
            },
            {
                "title": "The Ancient Temple",
                "description": "You stumble upon moss-covered ruins with mysterious frog hieroglyphs.",
                "choices": {
                    "1": ("Enter the temple", self.enter_temple),
                    "2": ("Study the hieroglyphs", self.study_hieroglyphs),
                    "3": ("Use your ability to explore", self.use_ability)
                }
            },
            {
                "title": "The Great Migration",
                "description": "Hundreds of frogs are migrating, but a fallen tree blocks their path!",
                "choices": {
                    "1": ("Try to move the tree", self.move_tree),
                    "2": ("Find an alternate route", self.find_route),
                    "3": ("Use your ability to help", self.use_ability)
                }
            }
        ]
        
        scenario = random.choice(scenarios)
        print(f"\n✨ {scenario['title']} ✨")
        print(f"\n{scenario['description']}")
        print("\nWhat do you do?")
        
        for key, (choice_text, _) in scenario['choices'].items():
            print(f"{key}. {choice_text}")
        
        while True:
            choice = input("\nYour choice (1-3): ").strip()
            if choice in scenario['choices']:
                _, action = scenario['choices'][choice]
                action(scenario['title'])
                break
            else:
                print("Please choose 1, 2, or 3")
    
    def pond_dive(self, scenario_title):
        self.current_frog.energy -= 20
        if random.random() > 0.5:
            self.current_frog.items.append("✨ Glowing Pearl")
            self.current_frog.happiness += 20
            print("\nYou dive deep and find a magical glowing pearl!")
        else:
            self.current_frog.happiness -= 10
            print("\nThe water is colder than expected! You surface quickly, shivering.")
    
    def use_ability(self, scenario_title):
        if self.current_frog.frog_type == FrogType.CUSTOM:
            print(f"\nYou use your {self.current_frog.ability}!")
            print("The results are spectacular!")
        else:
            ability_outcomes = {
                FrogType.TREE_FROG: "You climb high into the trees and spot the perfect solution!",
                FrogType.POISON_DART_FROG: "Your bright colors ward off any danger, making exploration safe!",
                FrogType.BULLFROG: "With a mighty leap, you overcome the obstacle easily!",
                FrogType.GLASS_FROG: "Nearly invisible, you sneak past all dangers undetected!",
                FrogType.ROCKET_FROG: "You zip around at incredible speed, solving the problem in seconds!",
                FrogType.RAIN_FROG: "You sense the perfect weather conditions and time your actions perfectly!"
            }
            print(f"\n{ability_outcomes[self.current_frog.frog_type]}")
        
        self.current_frog.energy -= 10
        self.current_frog.happiness += 30
        
        if random.random() > 0.3:
            items = ["🌺 Rare Flower", "🍄 Magic Mushroom", "💎 Tiny Crystal", "🌟 Stardust"]
            item = random.choice(items)
            self.current_frog.items.append(item)
            print(f"Your special ability helped you find: {item}!")
    
    def investigate_area(self, scenario_title):
        findings = [
            "You find ancient frog footprints leading somewhere interesting...",
            "A friendly beetle shares local wisdom with you!",
            "You discover a hidden cache of tasty flies!"
        ]
        print(f"\n{random.choice(findings)}")
        self.current_frog.energy -= 5
        self.current_frog.happiness += 10
    
    def search_stream(self, scenario_title):
        self.current_frog.energy -= 15
        print("\nYou search carefully through the reeds and rocks...")
        if random.random() > 0.4:
            print("Success! You reunite the tadpole with its family!")
            self.current_frog.happiness += 40
            self.current_frog.items.append("🏅 Hero Medal")
        else:
            print("No luck yet, but you'll keep trying!")
            self.current_frog.happiness += 10
    
    def comfort_tadpole(self, scenario_title):
        print("\nYou sing a soothing frog song to calm the tadpole.")
        self.current_frog.happiness += 20
        print("The tadpole feels better and remembers which way its family went!")
    
    def enter_temple(self, scenario_title):
        print("\nYou hop bravely into the ancient temple...")
        self.current_frog.energy -= 10
        if random.random() > 0.5:
            self.current_frog.items.append("📜 Ancient Scroll")
            print("You discover the wisdom of the ancient frogs!")
            self.current_frog.happiness += 30
        else:
            print("The temple is dark and spooky, but you're brave!")
    
    def study_hieroglyphs(self, scenario_title):
        print("\nThe hieroglyphs tell stories of legendary frog heroes!")
        self.current_frog.happiness += 15
        self.current_frog.items.append("📖 History Knowledge")
    
    def move_tree(self, scenario_title):
        if self.current_frog.frog_type == FrogType.BULLFROG:
            print("\nWith your incredible strength, you push the tree aside!")
            self.current_frog.happiness += 50
            self.current_frog.items.append("🦸 Strength Champion Badge")
        else:
            print("\nYou try your best, inspiring others to help!")
            self.current_frog.energy -= 20
            self.current_frog.happiness += 20
    
    def find_route(self, scenario_title):
        print("\nYou scout ahead and find a safe detour through the lily pads!")
        self.current_frog.happiness += 25
        self.current_frog.energy -= 10
    
    def save_game(self):
        if not self.current_frog:
            return
        
        save_data = {
            "frog": {
                "name": self.current_frog.name,
                "type": self.current_frog.frog_type.value,
                "ability": self.current_frog.ability,
                "description": self.current_frog.description,
                "energy": self.current_frog.energy,
                "happiness": self.current_frog.happiness,
                "items": self.current_frog.items,
                "species": self.current_frog.species,
                "personality": self.current_frog.personality,
                "backstory": self.current_frog.backstory
            },
            "adventures_completed": self.adventures_completed
        }
        
        with open(self.save_file, 'w') as f:
            json.dump(save_data, f, indent=2)
        print("\n💾 Game saved!")
    
    def load_game(self) -> bool:
        if not os.path.exists(self.save_file):
            return False
        
        try:
            with open(self.save_file, 'r') as f:
                save_data = json.load(f)
            
            frog_data = save_data["frog"]
            frog_type = next(ft for ft in FrogType if ft.value == frog_data["type"])
            
            self.current_frog = Frog(
                name=frog_data["name"],
                frog_type=frog_type,
                ability=frog_data["ability"],
                description=frog_data["description"],
                energy=frog_data["energy"],
                happiness=frog_data["happiness"],
                items=frog_data["items"],
                species=frog_data.get("species", ""),
                personality=frog_data.get("personality", ""),
                backstory=frog_data.get("backstory", "")
            )
            self.adventures_completed = save_data["adventures_completed"]
            return True
        except:
            return False
    
    def rest_frog(self):
        if self.current_frog.energy < 100:
            self.current_frog.energy = min(100, self.current_frog.energy + 30)
            print("\n😴 Your frog takes a refreshing nap on a lily pad!")
        else:
            print("\n🐸 Your frog is already full of energy!")
    
    def feed_frog(self):
        self.current_frog.happiness = min(100, self.current_frog.happiness + 20)
        print("\n🦟 Yummy flies! Your frog is happy!")
    
    def main_menu(self):
        print("\n🐸 Welcome to Frog Adventure! 🐸")
        print("=" * 30)
        
        if self.load_game():
            print("\n📂 Save game found!")
            self.display_frog_status()
            print("\n1. Continue adventure")
            print("2. Start new adventure")
            choice = input("\nYour choice: ").strip()
            
            if choice == "2":
                self.current_frog = None
                self.adventures_completed = 0
        
        if not self.current_frog:
            print("\n🎲 Let's meet your frog companion!")
            input("Press Enter to meet your random frog...")
            self.current_frog = self.get_random_frog()
            self.display_frog_status()
            input("\nPress Enter to begin your adventure...")
    
    def game_loop(self):
        self.main_menu()
        
        while True:
            print("\n" + "=" * 40)
            self.display_frog_status()
            print("\n" + "=" * 40)
            print("\nWhat would you like to do?")
            print("1. 🗺️  Go on an adventure")
            print("2. 😴 Rest (restore energy)")
            print("3. 🦟 Feed your frog (increase happiness)")
            print("4. 💾 Save game")
            print("5. 🔄 Switch to a new frog")
            print("6. 🚪 Exit game")
            
            choice = input("\nYour choice: ").strip()
            
            if choice == "1":
                if self.current_frog.energy < 20:
                    print("\n😴 Your frog is too tired! Please rest first.")
                else:
                    self.start_adventure()
                    self.adventures_completed += 1
                    print(f"\n✨ Adventure complete! Total adventures: {self.adventures_completed}")
            elif choice == "2":
                self.rest_frog()
            elif choice == "3":
                self.feed_frog()
            elif choice == "4":
                self.save_game()
            elif choice == "5":
                print("\n👋 Say goodbye to", self.current_frog.name + "!")
                self.current_frog = self.get_random_frog()
                print("\n🎉 Meet your new friend!")
                self.display_frog_status()
            elif choice == "6":
                print("\n👋 Thanks for playing Frog Adventure!")
                save = input("Save before exiting? (y/n): ").strip().lower()
                if save == 'y':
                    self.save_game()
                break
            else:
                print("\n❓ Please choose a valid option (1-6)")

if __name__ == "__main__":
    game = Adventure()
    game.game_loop()