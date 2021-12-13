
class RER_BestiaryArachas extends RER_BestiaryEntry {
  public function init() {
    var influences: RER_ConstantInfluences;
    influences = RER_ConstantInfluences();

    this.type = CreatureARACHAS;
    this.menu_name = 'Arachas';
    this.localized_name = 'option_rer_arachas';

    this.template_list.templates.PushBack(
      makeEnemyTemplate(
        "characters\npc_entities\monsters\arachas_lvl1.w2ent",,,
        "gameplay\journal\bestiary\bestiarycrabspider.journal"
      )
    );
    this.template_list.templates.PushBack(
      makeEnemyTemplate(
        "characters\npc_entities\monsters\arachas_lvl2__armored.w2ent", 2,,
        "gameplay\journal\bestiary\armoredarachas.journal"
      )
    );
    this.template_list.templates.PushBack(
      makeEnemyTemplate(
        "characters\npc_entities\monsters\arachas_lvl3__poison.w2ent", 2,,
        "gameplay\journal\bestiary\poisonousarachas.journal"
      )
    );

      this.template_list.difficulty_factor.minimum_count_easy = 1;
      this.template_list.difficulty_factor.maximum_count_easy = 2;
      this.template_list.difficulty_factor.minimum_count_medium = 2;
      this.template_list.difficulty_factor.maximum_count_medium = 3;
      this.template_list.difficulty_factor.minimum_count_hard = 3;
      this.template_list.difficulty_factor.maximum_count_hard = 4;

    this.trophy_names.PushBack('modrer_insectoid_trophy_low');
    this.trophy_names.PushBack('modrer_insectoid_trophy_medium');
    this.trophy_names.PushBack('modrer_insectoid_trophy_high');

    this.ecosystem_delay_multiplier = 9;

    this.ecosystem_impact = (new EcosystemCreatureImpactBuilder in thePlayer)
      .influence(influences.kills_them) //CreatureHUMAN
      .influence(influences.self_influence) //CreatureARACHAS
      .influence(influences.friend_with) //CreatureENDREGA
      .influence(influences.low_indirect_influence) //CreatureGHOUL
      .influence(influences.low_indirect_influence) //CreatureALGHOUL
      .influence(influences.high_indirect_influence) //CreatureNEKKER
      .influence(influences.low_indirect_influence) //CreatureDROWNER
      .influence(influences.low_indirect_influence) //CreatureROTFIEND
      .influence(influences.no_influence) //CreatureWOLF
      .influence(influences.no_influence) //CreatureWRAITH
      .influence(influences.no_influence) //CreatureHARPY
      .influence(influences.friend_with) //CreatureSPIDER
      .influence(influences.low_indirect_influence) //CreatureCENTIPEDE
      .influence(influences.low_indirect_influence) //CreatureDROWNERDLC
      .influence(influences.friend_with) //CreatureBOAR
      .influence(influences.friend_with) //CreatureBEAR
      .influence(influences.friend_with) //CreaturePANTHER
      .influence(influences.no_influence) //CreatureSKELETON
      .influence(influences.friend_with) //CreatureECHINOPS
      .influence(influences.low_indirect_influence) //CreatureKIKIMORE
      .influence(influences.no_influence) //CreatureBARGHEST
      .influence(influences.friend_with) //CreatureSKELWOLF
      .influence(influences.friend_with) //CreatureSKELBEAR
      .influence(influences.no_influence) //CreatureWILDHUNT
      .influence(influences.no_influence) //CreatureBERSERKER
      .influence(influences.no_influence) //CreatureSIREN

      // large creatures below
      .influence(influences.no_influence) //CreatureDRACOLIZARD
      .influence(influences.no_influence) //CreatureGARGOYLE
      .influence(influences.friend_with) //CreatureLESHEN
      .influence(influences.high_bad_influence) //CreatureWEREWOLF
      .influence(influences.friend_with) //CreatureFIEND
      .influence(influences.no_influence) //CreatureEKIMMARA
      .influence(influences.no_influence) //CreatureKATAKAN
      .influence(influences.no_influence) //CreatureGOLEM
      .influence(influences.no_influence) //CreatureELEMENTAL
      .influence(influences.no_influence) //CreatureNIGHTWRAITH
      .influence(influences.no_influence) //CreatureNOONWRAITH
      .influence(influences.friend_with) //CreatureCHORT
      .influence(influences.no_influence) //CreatureCYCLOP
      .influence(influences.no_influence) //CreatureTROLL
      .influence(influences.high_bad_influence) //CreatureHAG
      .influence(influences.high_bad_influence) //CreatureFOGLET
      .influence(influences.high_bad_influence) //CreatureBRUXA
      .influence(influences.no_influence) //CreatureFLEDER
      .influence(influences.no_influence) //CreatureGARKAIN
      .influence(influences.high_bad_influence) //CreatureDETLAFF
      .influence(influences.high_bad_influence) //CreatureGIANT
      .influence(influences.high_bad_influence) //CreatureSHARLEY
      .influence(influences.no_influence) //CreatureWIGHT
      .influence(influences.high_bad_influence) //CreatureGRYPHON
      .influence(influences.high_bad_influence) //CreatureCOCKATRICE
      .influence(influences.high_bad_influence) //CreatureBASILISK
      .influence(influences.high_bad_influence) //CreatureWYVERN
      .influence(influences.high_bad_influence) //CreatureFORKTAIL
      .influence(influences.no_influence) //CreatureSKELTROLL
      .build();
    
    this.possible_compositions.PushBack(CreatureENDREGA);
  }

  public function setCreaturePreferences(preferences: RER_CreaturePreferences, encounter_type: EncounterType): RER_CreaturePreferences{
    return super.setCreaturePreferences(preferences, encounter_type)
    .addDislikedBiome(BiomeSwamp)
    .addDislikedBiome(BiomeWater)
    .addLikedBiome(BiomeForest);
  }
}
