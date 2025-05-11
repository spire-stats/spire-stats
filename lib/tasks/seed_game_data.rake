namespace :game_data do
  desc "Seed initial cards and relics data from Slay the Spire"
  task seed: :environment do
    puts "Seeding cards data..."

    # Ironclad cards
    ironclad_cards = [
      { name: "Strike", card_type: "Attack", rarity: "Basic", cost: 1, character: "IRONCLAD", description: "Deal 6 damage.", base_version: true },
      { name: "Defend", card_type: "Skill", rarity: "Basic", cost: 1, character: "IRONCLAD", description: "Gain 5 Block.", base_version: true },
      { name: "Bash", card_type: "Attack", rarity: "Basic", cost: 2, character: "IRONCLAD", description: "Deal 8 damage. Apply 2 Vulnerable.", base_version: true },
      { name: "Anger", card_type: "Attack", rarity: "Common", cost: 0, character: "IRONCLAD", description: "Deal 6 damage. Add a copy of this card to your discard pile.", base_version: true },
      { name: "Armaments", card_type: "Skill", rarity: "Common", cost: 1, character: "IRONCLAD", description: "Gain 5 Block. Upgrade a card in your hand for the rest of combat.", base_version: true },
      { name: "Body Slam", card_type: "Attack", rarity: "Common", cost: 1, character: "IRONCLAD", description: "Deal damage equal to your Block.", base_version: true }
      # Add more Ironclad cards as needed
    ]

    # Silent cards
    silent_cards = [
      { name: "Strike", card_type: "Attack", rarity: "Basic", cost: 1, character: "THE_SILENT", description: "Deal 6 damage.", base_version: true },
      { name: "Defend", card_type: "Skill", rarity: "Basic", cost: 1, character: "THE_SILENT", description: "Gain 5 Block.", base_version: true },
      { name: "Neutralize", card_type: "Attack", rarity: "Basic", cost: 0, character: "THE_SILENT", description: "Deal 3 damage. Apply 1 Weak.", base_version: true },
      { name: "Survivor", card_type: "Skill", rarity: "Basic", cost: 1, character: "THE_SILENT", description: "Gain 8 Block. Discard 1 card.", base_version: true },
      { name: "Acrobatics", card_type: "Skill", rarity: "Common", cost: 1, character: "THE_SILENT", description: "Draw 3 cards. Discard 1 card.", base_version: true }
      # Add more Silent cards as needed
    ]

    # Defect cards
    defect_cards = [
      { name: "Strike", card_type: "Attack", rarity: "Basic", cost: 1, character: "DEFECT", description: "Deal 6 damage.", base_version: true },
      { name: "Defend", card_type: "Skill", rarity: "Basic", cost: 1, character: "DEFECT", description: "Gain 5 Block.", base_version: true },
      { name: "Zap", card_type: "Skill", rarity: "Basic", cost: 1, character: "DEFECT", description: "Channel 1 Lightning.", base_version: true },
      { name: "Dualcast", card_type: "Skill", rarity: "Basic", cost: 1, character: "DEFECT", description: "Evoke your next Orb twice.", base_version: true }
      # Add more Defect cards as needed
    ]

    # Watcher cards
    watcher_cards = [
      { name: "Strike", card_type: "Attack", rarity: "Basic", cost: 1, character: "WATCHER", description: "Deal 6 damage.", base_version: true },
      { name: "Defend", card_type: "Skill", rarity: "Basic", cost: 1, character: "WATCHER", description: "Gain 5 Block.", base_version: true },
      { name: "Eruption", card_type: "Attack", rarity: "Basic", cost: 2, character: "WATCHER", description: "Deal 9 damage. Enter Wrath.", base_version: true },
      { name: "Vigilance", card_type: "Skill", rarity: "Basic", cost: 2, character: "WATCHER", description: "Gain 8 Block. Enter Calm.", base_version: true }
      # Add more Watcher cards as needed
    ]

    # Colorless cards
    colorless_cards = [
      { name: "Shiv", card_type: "Attack", rarity: "Special", cost: 0, character: nil, description: "Deal 4 damage. Exhaust.", base_version: true },
      { name: "Bite", card_type: "Attack", rarity: "Special", cost: 1, character: nil, description: "Deal 7 damage. Heal 2 HP.", base_version: true },
      { name: "Slimed", card_type: "Status", rarity: "Special", cost: 1, character: nil, description: "Exhaust.", base_version: true },
      { name: "Wound", card_type: "Status", rarity: "Special", cost: -1, character: nil, description: "Unplayable.", base_version: true },
      { name: "Burn", card_type: "Status", rarity: "Special", cost: -1, character: nil, description: "Unplayable. At the end of your turn, take 2 damage.", base_version: true }
      # Add more Colorless cards as needed
    ]

    # Combine all cards and create records
    all_cards = ironclad_cards + silent_cards + defect_cards + watcher_cards + colorless_cards

    # Create card records or update existing ones
    all_cards.each do |card_data|
      card = Card.find_or_initialize_by(name: card_data[:name], character: card_data[:character])
      card.update!(card_data)
      puts "Seeded card: #{card.name} (#{card.character || 'Colorless'})"
    end

    puts "Seeded #{all_cards.size} cards."

    puts "\nSeeding relics data..."

    # Define relics data
    common_relics = [
      { name: "Blood Vial", rarity: "Common", character: nil, description: "At the start of each combat, heal 2 HP.", flavor_text: "A vial containing the blood of a pure and elder vampire." },
      { name: "Bronze Scales", rarity: "Common", character: nil, description: "Whenever you take damage, deal 3 damage back.", flavor_text: "The sharp scales of the Guardian. Rearranges itself to protect its user." },
      { name: "Bag of Marbles", rarity: "Common", character: nil, description: "At the start of each combat, apply 1 Vulnerable to ALL enemies.", flavor_text: "Once common in the area, the marbles are now prized for their mystical properties." }
      # Add more common relics
    ]

    uncommon_relics = [
      { name: "Bottle Flame", rarity: "Uncommon", character: nil, description: "Upon pickup, choose an Attack card. Start each combat with this card in your hand.", flavor_text: "Inside the bottle, a flame burns eternally." },
      { name: "Bottled Lightning", rarity: "Uncommon", character: nil, description: "Upon pickup, choose a Skill card. Start each combat with this card in your hand.", flavor_text: "Peering into the swirling storm, you see a glimpse of yourself." },
      { name: "Bottled Tornado", rarity: "Uncommon", character: nil, description: "Upon pickup, choose a Power card. Start each combat with this card in your hand.", flavor_text: "The bottle gently hums and whirs." }
      # Add more uncommon relics
    ]

    rare_relics = [
      { name: "Bird-Faced Urn", rarity: "Rare", character: nil, description: "Whenever you play a Power card, heal 2 HP.", flavor_text: "This urn shows the crow god Mazaleth looking mischievous." },
      { name: "Calipers", rarity: "Rare", character: nil, description: "At the start of your turn, lose 15 Block rather than all of your Block.", flavor_text: "\"Mechanical precision leads to greatness\" - The Architect" },
      { name: "Champion Belt", rarity: "Rare", character: nil, description: "Whenever you apply Vulnerable, also apply 1 Weak.", flavor_text: "Only the greatest may wear this belt." }
      # Add more rare relics
    ]

    boss_relics = [
      { name: "Black Star", rarity: "Boss", character: nil, description: "Elites drop an additional relic when defeated.", flavor_text: "Originally discovered in a town that was split by a black meteor." },
      { name: "Calling Bell", rarity: "Boss", character: nil, description: "Upon pickup, obtain a unique Curse and 3 relics.", flavor_text: "This dark iron bell rang once when you found it, but now stays silent." },
      { name: "Ectoplasm", rarity: "Boss", character: nil, description: "Gain 1 Energy at the start of each turn. You can no longer gain Gold.", flavor_text: "This blob appears to be pure energy, impossible to interact with." }
      # Add more boss relics
    ]

    character_relics = [
      { name: "Burning Blood", rarity: "Starter", character: "IRONCLAD", description: "At the end of combat, heal 6 HP.", flavor_text: "Your body never stops burning with fury." },
      { name: "Ring of the Snake", rarity: "Starter", character: "THE_SILENT", description: "At the start of each combat, draw 2 additional cards.", flavor_text: "Made from a fossilized snake. Represents great skill as a huntress." },
      { name: "Cracked Core", rarity: "Starter", character: "DEFECT", description: "At the start of each combat, channel 1 Lightning.", flavor_text: "The mysterious lifeforce that powers the automatons. It appears to be cracked." },
      { name: "Pure Water", rarity: "Starter", character: "WATCHER", description: "At the start of each combat, add a Miracle to your hand.", flavor_text: "Filtered through fine sand and free of impurities." }
      # Add more character-specific relics
    ]

    # Combine all relics
    all_relics = common_relics + uncommon_relics + rare_relics + boss_relics + character_relics

    # Create relic records or update existing ones
    all_relics.each do |relic_data|
      relic = Relic.find_or_initialize_by(name: relic_data[:name])
      relic.update!(relic_data)
      puts "Seeded relic: #{relic.name} (#{relic.rarity})"
    end

    puts "Seeded #{all_relics.size} relics."

    puts "\nSeeding complete!"
  end
end
