
state KneelInteraction in RandomEncountersReworkedContractEntity {
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('modRandomEncounters', "Contract - State KneelInteraction");

    this.KneelInteraction_main();
  }

  entry function KneelInteraction_main() {

  }
}
