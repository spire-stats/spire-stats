require 'rails_helper'

RSpec.describe EnemyEncounter, type: :model do
  describe '.process_for_run' do
    let!(:user) { User.create!(email: 'test@example.com', password: 'password', confirmed_at: Time.current) }
    let!(:run_file) { RunFile.create!(user: user, run_data: { 'seed' => 'TESTSEED123', 'character_chosen' => 'IRONCLAD' }) }

    let(:base_run_attributes) do
      {
        user: user,
        run_file: run_file,
        character: 'IRONCLAD',
        seed: 'TESTSEED123',
        floor_reached: 0,
        victory: false
      }
    end

    let(:run) { Run.create!(**base_run_attributes, killed_by: 'Some Future Enemy') }

    context 'when damage_taken_data is nil' do
      it 'does not create any enemy encounters' do
        expect {
          EnemyEncounter.process_for_run(run, nil)
        }.not_to change(EnemyEncounter, :count)
      end
    end

    context 'when damage_taken_data is empty' do
      it 'does not create any enemy encounters' do
        expect {
          EnemyEncounter.process_for_run(run, [])
        }.not_to change(EnemyEncounter, :count)
      end
    end

    context 'with a single regular encounter' do
      let(:damage_data) do
        [ { "enemies" => "2 Louses", "floor" => 1, "damage" => 5, "turns" => 2 } ]
      end

      it 'creates one enemy encounter' do
        expect {
          EnemyEncounter.process_for_run(run, damage_data)
        }.to change(EnemyEncounter, :count).by(1)
      end

      it 'assigns the correct attributes' do
        EnemyEncounter.process_for_run(run, damage_data)
        encounter = EnemyEncounter.last
        expect(encounter.run).to eq(run)
        expect(encounter.enemies).to eq("2 Louses")
        expect(encounter.floor).to eq(1)
        expect(encounter.damage_taken).to eq(5)
        expect(encounter.turns).to eq(2)
        expect(encounter.is_elite).to be_falsey
        expect(encounter.is_boss).to be_falsey
        expect(encounter.was_killing_blow).to be_falsey
      end
    end

    context 'with an elite encounter' do
      let(:damage_data) do
        [ { "enemies" => "Gremlin Nob", "floor" => 6, "damage" => 10, "turns" => 3 } ]
      end

      it 'creates one enemy encounter marked as elite' do
        EnemyEncounter.process_for_run(run, damage_data)
        encounter = EnemyEncounter.last
        expect(encounter.is_elite).to be_truthy
        expect(encounter.is_boss).to be_falsey
      end
    end

    context 'with a boss encounter' do
      let(:damage_data) do
        [ { "enemies" => "The Guardian", "floor" => 17, "damage" => 20, "turns" => 5 } ]
      end

      it 'creates one enemy encounter marked as boss' do
        EnemyEncounter.process_for_run(run, damage_data)
        encounter = EnemyEncounter.last
        expect(encounter.is_elite).to be_falsey
        expect(encounter.is_boss).to be_truthy
      end
    end

    context 'when the encounter was the killing blow' do
      let(:run_killed) { Run.create!(**base_run_attributes, user: user, run_file: run_file, killed_by: "Jaw Worm", floor_reached: 3) }
      let(:damage_data) do
        [ { "enemies" => "Jaw Worm", "floor" => 3, "damage" => 15, "turns" => 4 } ]
      end

      it 'marks the encounter as the killing blow' do
        EnemyEncounter.process_for_run(run_killed, damage_data)
        encounter = EnemyEncounter.last
        expect(encounter.was_killing_blow).to be_truthy
      end
    end

    context 'when the encounter was not the killing blow' do
      let(:run_survived_this_fight) { Run.create!(**base_run_attributes, user: user, run_file: run_file, killed_by: "Slime Boss", floor_reached: 17) }
      let(:damage_data) do
        [ { "enemies" => "Jaw Worm", "floor" => 3, "damage" => 15, "turns" => 4 } ]
      end

      it 'does not mark the encounter as the killing blow' do
        EnemyEncounter.process_for_run(run_survived_this_fight, damage_data)
        encounter = EnemyEncounter.last
        expect(encounter.was_killing_blow).to be_falsey
      end
    end

    context 'with multiple encounters' do
      let(:multi_encounter_run) { Run.create!(**base_run_attributes, user: user, run_file: run_file, killed_by: 'Hexaghost', floor_reached: 17) }
      let(:damage_data) do
        [
          { "enemies" => "Cultist", "floor" => 1, "damage" => 0, "turns" => 1 },
          { "enemies" => "Lagavulin", "floor" => 7, "damage" => 22, "turns" => 4 },
          { "enemies" => "Hexaghost", "floor" => 17, "damage" => 30, "turns" => 6 }
        ]
      end

      it 'creates three enemy encounters' do
        expect {
          EnemyEncounter.process_for_run(multi_encounter_run, damage_data)
        }.to change(EnemyEncounter, :count).by(3)
      end

      it 'assigns attributes correctly for multiple encounters' do
        EnemyEncounter.process_for_run(multi_encounter_run, damage_data)
        encounters = multi_encounter_run.enemy_encounters.order(:floor)

        expect(encounters[0].enemies).to eq("Cultist")
        expect(encounters[0].is_elite).to be_falsey
        expect(encounters[0].is_boss).to be_falsey
        expect(encounters[0].was_killing_blow).to be_falsey

        expect(encounters[1].enemies).to eq("Lagavulin")
        expect(encounters[1].is_elite).to be_truthy
        expect(encounters[1].is_boss).to be_falsey
        expect(encounters[1].was_killing_blow).to be_falsey

        expect(encounters[2].enemies).to eq("Hexaghost")
        expect(encounters[2].is_elite).to be_falsey
        expect(encounters[2].is_boss).to be_truthy
        expect(encounters[2].was_killing_blow).to be_truthy
      end
    end
  end
end
