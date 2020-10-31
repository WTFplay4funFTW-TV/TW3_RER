
class RandomEncountersReworkedEntity extends CEntity {
  // an invisible entity used to bait the entity
  // do i really need a CEntity?
  // using ActionMoveTo i can force the creature to go
  // toward a vector.
  // Leaving the question here, but yes i tried for
  // a full week to make the functions ActionMoveTo work
  // but nothing worked as expected. So a bait is the best
  // thing. 
  var bait_entity: CEntity;

  // control whether the entity goes towards a bait
  // or the player
  var go_towards_bait: bool;
  default go_towards_bait = false;

  public var this_entity: CEntity;
  public var this_actor: CActor;
  public var this_newnpc: CNewNPC;

  public var automatic_kill_threshold_distance: float;
  default automatic_kill_threshold_distance = 200;

  private var master: CRandomEncounters;

  public var pickup_animation_on_death: bool;
  default pickup_animation_on_death = false;

  private var trail_maker: RER_TrailMaker;

  event OnSpawned( spawnData : SEntitySpawnData ){
    super.OnSpawned(spawnData);

    LogChannel('modRandomEncounters', "RandomEncountersEntity spawned");
  }

  public function attach(actor: CActor, newnpc: CNewNPC, this_entity: CEntity, master: CRandomEncounters) {
    this.this_actor = actor;
    this.this_newnpc = newnpc;
    this.this_entity = this_entity;
    
    this.master = master;

    this.CreateAttachment( this_entity );
    this.AddTag('RandomEncountersReworked_Entity');
  }

  public function removeAllLoot() {
    var inventory: CInventoryComponent;

    inventory = this.this_actor.GetInventory();

    inventory.EnableLoot(false);
  }

  // entry point when creating an entity who will
  // follow a bait and leave tracks behind her.
  // more suited for: `EncounterType_HUNT`
  // NOTE: this functions calls `startWithoutBait`
  public latent function startWithBait(bait_entity: CEntity) {
    var tracks_templates: array<CEntityTemplate>;

    this.bait_entity = bait_entity;
    this.go_towards_bait = true;

    ((CNewNPC)this.bait_entity).SetGameplayVisibility(false);
    ((CNewNPC)this.bait_entity).SetVisibility(false);
    ((CActor)this.bait_entity).EnableCharacterCollisions(false);
    ((CActor)this.bait_entity).EnableDynamicCollisions(false);
    ((CActor)this.bait_entity).EnableStaticCollisions(false);
    ((CActor)this.bait_entity).SetImmortalityMode(AIM_Immortal, AIC_Default);

    tracks_templates.PushBack(getTracksTemplate(this.this_actor));

    this.trail_maker = new RER_TrailMaker in this;
    this.trail_maker.init(
      this.master.settings.foottracks_ratio,
      200,
      tracks_templates
    );

    // to calculate the initial position we go from the
    // monsters position and use the inverse tracks_heading to
    // cross ThePlayer's path.
    this.trail_maker
      .drawTrail(
        VecInterpolate(
          this.GetWorldPosition(),
          thePlayer.GetWorldPosition(),
          1.3
        ),

        this.GetWorldPosition(),
        20,,,
        true
      );

    this.startWithoutBait();
  }

  // entry point when creating an entity who will
  // directly target the player.
  // more suited for: `EncounterType_DEFAULT`
  public function startWithoutBait() {
    LogChannel('modRandomEncounters', "starting - automatic death threshold = " + this.automatic_kill_threshold_distance);

    if (this.go_towards_bait) {
      AddTimer('intervalHuntFunction', 2, true);
      AddTimer('teleportBait', 10, true);
    }
    else {
      this.this_newnpc.NoticeActor(thePlayer);
      this.this_newnpc.SetAttitude(thePlayer, AIA_Hostile);

      AddTimer('intervalDefaultFunction', 2, true);

      this.this_actor
        .ActionMoveToNodeAsync(thePlayer);
    }
  }

  timer function intervalDefaultFunction(optional dt : float, optional id : Int32) {
    var distance_from_player: float;

    if (!this.this_actor.IsAlive()) {
      this.clean();

      return;
    }

    distance_from_player = VecDistance(
      this.GetWorldPosition(),
      thePlayer.GetWorldPosition()
    );

    if (distance_from_player > this.automatic_kill_threshold_distance) {
      LogChannel('modRandomEncounters', "killing entity - threshold distance reached: " + this.automatic_kill_threshold_distance);
      this.clean();

      return;
    }

    LogChannel('modRandomEncounters', "distance from player : " + distance_from_player);

    this.this_newnpc.NoticeActor(thePlayer);

    if (distance_from_player < 20) {
      // the creature is close enough to fight thePlayer,
      // we do not need this intervalFunction anymore.
      this.RemoveTimer('intervalDefaultFunction');

      // so it is also called almost instantly
      this.AddTimer('intervalLifecheckFunction', 0.1, false);
      this.AddTimer('intervalLifecheckFunction', 1, true);
    }
  }

  timer function intervalHuntFunction(optional dt : float, optional id : Int32) {
    var distance_from_player: float;
    var distance_from_bait: float;
    var new_bait_position: Vector;
    var new_bait_rotation: EulerAngles;

    if (!this.this_newnpc.IsAlive()) {
      this.clean();

      return;
    }

    distance_from_player = VecDistance(
      this.GetWorldPosition(),
      thePlayer.GetWorldPosition()
    );

    distance_from_bait = VecDistance(
      this.GetWorldPosition(),
      this.bait_entity.GetWorldPosition()
    );

    LogChannel('modRandomEncounters', "distance from player : " + distance_from_player);
    LogChannel('modRandomEncounters', "distance from bait : " + distance_from_bait);

    if (distance_from_player > this.automatic_kill_threshold_distance) {
      LogChannel('modRandomEncounters', "killing entity - threshold distance reached: " + this.automatic_kill_threshold_distance);
      this.clean();

      return;
    }

    if (distance_from_player < 20) {
      this.this_actor
        .ActionCancelAll();

      this.this_newnpc.NoticeActor(thePlayer);
      this.this_newnpc.SetAttitude(thePlayer, AIA_Hostile);

      // the creature is close enough to fight thePlayer,
      // we do not need this intervalFunction anymore.
      this.RemoveTimer('intervalHuntFunction');
      this.RemoveTimer('teleportBait');
      this.AddTimer('intervalLifecheckFunction', 1, true);

      // we also kill the bait
      this.bait_entity.Destroy();
    }
    else {
      // https://github.com/Aelto/W3_RandomEncounters_Tweaks/issues/6:
      // when the bait_entity is no longer in the game, force the creatures
      // to target the player instead.
      if (this.bait_entity) {
        this.this_newnpc.NoticeActor((CActor)this.bait_entity);

        this.this_actor
        .ActionMoveToAsync(this.bait_entity.GetWorldPosition());

        if (distance_from_bait < 5) {
          new_bait_position = this.GetWorldPosition() + VecConeRand(this.GetHeading(), 90, 10, 20);
          new_bait_rotation = this.GetWorldRotation();
          
          this.bait_entity.TeleportWithRotation(
            new_bait_position,
            new_bait_rotation
          );
        }
      }
      else {
        // to avoid creatures who lost their bait (because it went too far)
        // aggroing the player. But instead they die too.
        if (distance_from_player > this.automatic_kill_threshold_distance * 0.8) {
          LogChannel('modRandomEncounters', "killing entity - threshold distance reached: " + this.automatic_kill_threshold_distance);
          this.clean();

          return;
        }

        this.this_newnpc.NoticeActor(thePlayer);
      }

      this.trail_maker.addTrackHere(this.GetWorldPosition(), this.GetWorldRotation());
    }  
  }



  // simple interval function called every ten seconds or so to check if the creature is
  // still alive. Starts the cleaning process if not, and eventually triggers some events.
  timer function intervalLifecheckFunction(optional dt: float, optional id: Int32) {
    var distance_from_player: float;

    if (!this.this_newnpc.IsAlive()) {
      this.clean();

      return;
    }

    distance_from_player = VecDistance(
      this.GetWorldPosition(),
      thePlayer.GetWorldPosition()
    );

    if (distance_from_player > this.automatic_kill_threshold_distance) {
      LogChannel('modRandomEncounters', "killing entity - threshold distance reached: " + this.automatic_kill_threshold_distance);
      this.clean();

      return;
    }
  }

  // a timer function called every few seconds o teleport the bait.
  // In case the bait is in a position the creature can't reach
  timer function teleportBait(optional dt : float, optional id : Int32) {
    var new_bait_position: Vector;
    var new_bait_rotation: EulerAngles;

    new_bait_position = this.GetWorldPosition() + VecConeRand(this.GetHeading(), 90, 10, 20);
    new_bait_rotation = this.GetWorldRotation();
    new_bait_rotation.Yaw += RandRange(-20,20);
    
    this.bait_entity.TeleportWithRotation(
      new_bait_position,
      new_bait_rotation
    );
  }

  private function clean() {
    var i: int;
    var distance_from_player: float;

    RemoveTimer('intervalDefaultFunction');
    RemoveTimer('intervalHuntFunction');
    RemoveTimer('teleportBait');
    RemoveTimer('intervalLifecheckFunction');

    LogChannel('modRandomEncounters', "RandomEncountersReworked_Entity destroyed");

    if (this.bait_entity) {
      this.bait_entity.Destroy();
    }

    this.this_actor.Kill('RandomEncountersReworked_Entity', true);

    distance_from_player = VecDistance(
      this.GetWorldPosition(),
      thePlayer.GetWorldPosition()
    );

    // 20 here because the cutscene picksup everything around geralt
    // so the distance doesn't have to be too high.
    if (this.pickup_animation_on_death && distance_from_player < 20) {
      this.master.requestOutOfCombatAction(OutOfCombatRequest_TROPHY_CUTSCENE);
    }
    
    this.Destroy();
  }
}
