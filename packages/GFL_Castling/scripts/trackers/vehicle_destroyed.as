#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"
#include "GFLhelpers.as"
#include "GFLtask.as"
#include "task_sequencer.as"
#include "resource_helpers.as"
#include "GFLparameters.as"

//Author： rst

dictionary included_vehicle = {
        {"martina.vehicle",10000},
        {"chiara.vehicle",10000},
        {"pierre.vehicle",10000},
        {"aek999.vehicle",5000},
        {"amos.vehicle",500000},
        {"tricycle.vehicle",10000},
        {"gk_bunker.vehicle",20000},
        {"gk_bunker_tow.vehicle",20000},
        {"gk_bunker_mortar.vehicle",20000},
        {"gk_bunker_cannon.vehicle",20000},
        {"radar_tower.vehicle",500000},
        {"ogas_pulse_generator.vehicle",25000},
        {"t14_gk.vehicle",50000},
        {"is2_m1895.vehicle",50000},
        {"mobile_armory.vehicle",10000},
        {"mortar_truck.vehicle",10000},
        // {"gk_store",5000},
        {"elmostore",5000},
        // {"gk_stash",30000},
        // {"hvy_store",5000},
        // {"t6_store",5000},
        // {"call_ui_store",5000},
        {"armored_truck.vehicle",500000},
        {"",-1}
};

class vehicle_destroyed : Tracker{
    protected Metagame@ m_metagame;
    protected bool m_ended;

    //--------------------------------------------
    vehicle_destroyed(Metagame@ metagame){
        @m_metagame = @metagame;
        m_ended = false;
    }
    // --------------------------------------------
    void update(float time) {
    }
    // --------------------------------------------
	bool hasEnded() const {
		return false;
	}
	// --------------------------------------------
	bool hasStarted() const {
		return true;
	}
    

    // ----------------------------------------------------
	protected void handleMatchEndEvent(const XmlElement@ event) {
		m_ended = true;
	}

    protected void handleVehicleDestroyEvent(const XmlElement@ event) {
        string vehicle_name = event.getStringAttribute("vehicle_key");
        int vehicle_id = event.getIntAttribute("vehicle_id");
        int killer_cid = event.getIntAttribute("character_id");
        int killer_fid = event.getIntAttribute("faction_id");
        int vehicle_owner_fid = event.getIntAttribute("owner_id");
        // Vector3 position = stringToVector3(event.getStringAttribute("position"));

        if(!included_vehicle.exists(vehicle_name)){return;}
        if(killer_fid != vehicle_owner_fid){return;}

        const XmlElement@ characterInfo = getCharacterInfo(m_metagame, killer_cid);
        if(characterInfo is null){return;}
        int pid = characterInfo.getIntAttribute("player_id");
        if(pid == -1) return;

        const XmlElement@ vehicleInfo = getVehicleInfo(m_metagame, vehicle_id);
        if(vehicleInfo is null){return;}

        int rp_punish = int(included_vehicle[vehicle_name]);

        dictionary a;
        a["%count"] = ""+rp_punish;   
        notify(m_metagame, "Hint - Vehicle Destoryed TK", a , "misc", pid, false, "", 1.0);
        GiveRP(m_metagame,killer_cid,-rp_punish);
 	}    

}