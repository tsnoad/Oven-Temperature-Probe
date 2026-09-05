include <../Shared Libraries/common_params_and_modules.scad>;
include <../Shared Libraries/component_shared_modules.scad>;

$fn = 36;

include <../Shared Libraries/filament_colors_595C.scad>;
include <../Shared Libraries/materials.scad>;

// show_only_material = "stainless_steel";
// show_only_material = "brass";
// show_only_material = "plastic_black";
// show_only_material = "3dprint";

include <../Shared Libraries/components/screws.scad>;
include <../Shared Libraries/components/power_modules.scad>;
include <../Shared Libraries/components/esp32_boards.scad>;
include <../Shared Libraries/components/sensors.scad>;
include <../Shared Libraries/components/displays.scad>;
include <../Shared Libraries/components/misc_components.scad>;
include <../Shared Libraries/components/battery_holders.scad>;

include <../Shared Libraries/fonts/comfortaa.scad>;
include <../Shared Libraries/fonts/fontawesome.scad>;

show_bom = true;

base_hgt = 24;
base_floor_thk = 2;
base_floor_skin_thk = 0.8;
top_hgt = 3;

case_dim = [134,58,0];
case_crn_r = 3+clr_close+w6;
case_crn_trans = xyz_to_trans(case_dim/2)-outset_to_trans(case_crn_r);

wing_wid = 22;
case_with_wing_crn_trans = case_crn_trans+outset_xxyy_to_trans(0,1,0,0)*(clr_close+wing_wid);
wing_crn_trans = case_with_wing_crn_trans-outset_xxyy_to_trans(1,0,0,0)*(case_dim.x+clr_close);

tray_hgt = 6;
tray_z = base_hgt+top_hgt-max7219_display_hgt-tray_hgt;

operation_union = 1;
operation_difference = -1;
operation_union_nonintersect = 2;
operation_placeholder = 3;
operation_bom = 99;

part_base = 1;
part_tray = 2;
part_top = 3;
part_bom = 99;

*skeletion_view_intersect("red") {
    material_3dprint(color_595C_tan_525) part_base();
}
*skeletion_view_intersect("red") {
    material_3dprint(color_595C_tan_525) !part_tray();
}
*skeletion_view_intersect("red") {
    material_3dprint(color_595C_tan_525) part_top();
}

// feature_esp32c3_supermini(part_base,operation_placeholder);

for(i_part=[0:99]) features(i_part,operation_placeholder);
// features(part_bom,operation_bom);

module skeletion_view_intersect(color="red") {
    intersection() {
        children();
        // color(color) translate(-[1,0,0]*100) cube([2,2,2]*100);
        // color(color) translate(-[0,1,0]*100) cube([2,2,2]*100);
        // color(color) translate(magnet_trans[1]-[0,0,0]*100) cube([2,2,2]*100);

        color(color) translate([case_dim.x/2+clr_close+wing_wid+20/2,0,0]-[2,1,0]*100) cube([2,2,2]*100);
    }
}

module part_base() let(part_name=part_base) difference() {
    union() {
        difference() {
            // cylinder_bev(case_crn_r,base_hgt,bev_m,bev_m,case_with_wing_crn_trans);
            cylinder_bev(case_crn_r,base_hgt,bev_m,bev_m,case_crn_trans);
            translate([0,0,base_hgt]) cylinder_bev_co_blind_downwards(case_crn_r-w6,base_hgt-base_floor_skin_thk,bev_m,bev_m,0,case_crn_trans);
        }
        difference() {
            cylinder_bev(case_crn_r,base_floor_thk,bev_m,bev_m,case_crn_trans);
            translate([0,0,base_floor_thk]) trigrid_co_blind_downwards(0.5,17.5,110/2,base_floor_thk-base_floor_skin_thk,bev_m,bev_m);
        }
        *if(!is_undef(wing_wid) && wing_wid > 0) intersection() {
            cylinder_bev(case_crn_r,base_hgt+top_hgt,bev_m,bev_m,case_with_wing_crn_trans);
            translate([0,0,base_hgt-bev_m]) cylinder_bev_stud(case_crn_r,bev_m+top_hgt,bev_m+bev_s,bev_m,wing_crn_trans);
        }

        intersection() {
            features(part_name,operation_union);
            cylinder_bev(case_crn_r,base_hgt,bev_m,bev_m,case_crn_trans);
        }

        features(part_name,operation_union_nonintersect);
    }
    features(part_name,operation_difference);
}

module part_tray() difference() {
    tray_crn_r = 4;
    tray_crn_trans = let(crn_tmp=xyz_to_trans(case_dim/2)-outset_to_trans(tray_crn_r+w6+clr_free)) concat(crn_tmp-outset_xxyy_to_trans(1,1,0,0)*8,crn_tmp-outset_xxyy_to_trans(0,0,1,1)*8);

    union() {
        translate([0,0,tray_z]) cylinder_bev(tray_crn_r,tray_hgt,bev_m,bev_m,tray_crn_trans);

        intersection() {
            features(part_tray,operation_union);
            translate([0,0,tray_z]) cylinder_bev(tray_crn_r,tray_hgt,bev_m,bev_m,tray_crn_trans);
        }

        intersection() {
            features(part_tray,operation_union_nonintersect);
            translate([0,0,tray_z]) cylinder_bev(tray_crn_r,tray_hgt,bev_m,bev_m,xyz_to_trans(case_dim/2)-outset_to_trans(tray_crn_r+w6+clr_free));
        }
    }

    features(part_tray,operation_difference);
}

module part_top() difference() {
    union() {
        difference() {
            translate([0,0,base_hgt]) cylinder_bev(case_crn_r,top_hgt,bev_m,1,case_crn_trans);

            // cylinder_bev_co_through(case_crn_r-w6,base_hgt,bev_m,bev_m,0,case_crn_trans);
        }
    }
    features(part_top,operation_difference);
}


use_mcu_esp32c3_supermini     = 1;
use_mcu_esp32c3_superminiplus = 2;
use_mcu_esp32s3_supermini     = 3;

use_battery_18650 = 1;
use_battery_21700 = 2;

use_mcu = use_mcu_esp32c3_supermini;
use_battery = use_battery_21700;

battery_position = [-(max6675_pcb_dim.x-mhfmd_buzzer_pcb_dim.x)/2,0,0];

module features(part,operation) {
    feature_screws(part,operation);
    feature_feet(part,operation);
    feature_magnets(part,operation);

    // feature_probe_slot(part,operation);
    feature_cable_gland(part,operation);

    feature_tray_screws(part,operation);

    if(use_mcu == use_mcu_esp32c3_supermini) {
        feature_esp32c3_supermini(part,operation,[-1.6,case_dim.y/2,0],attach_bottomleft,0,6);
        feature_bms(part,operation,[0,case_dim.y/2,0],attach_bottomright,0,6);
    }
    if(use_mcu == use_mcu_esp32c3_superminiplus) {
        feature_esp32c3_superminiplus(part,operation,[0,case_dim.y/2,0],attach_bottom,0,6);
    }
    if(use_mcu == use_mcu_esp32s3_supermini) {
        feature_esp32s3_supermini(part,operation,[0,case_dim.y/2,0],attach_bottom,0,6);
    }
    
    max7219_display_position = [-1.5,-6,0];
    feature_max7219_display(part,operation,max7219_display_position+[0,case_dim.y/2,0],attach_bottom);

    if(use_battery == use_battery_18650) {
        feature_battery_18650(part,operation,battery_position+[0,-case_dim.y/2,0],attach_top,90);
    }
    if(use_battery == use_battery_21700) {
        feature_battery_21700(part,operation,battery_position+[0,-case_dim.y/2,0],attach_top,90);
    }

    feature_max6675(part,operation,battery_position+[44,0,0],attach_right,180);
    feature_buzzer(part,operation,battery_position-[44,0,0],attach_left);
}

module bom_item(part,operation,bom_item_name) {
    if(!is_undef(show_bom) && show_bom) if(part == part_bom && operation == operation_bom) {
        bom_feature = str(parent_module(1));
        echo(str("[BOM] [",bom_feature,"] ",bom_item_name));
    }
}

module base_boss_cylinder_bev(rad,hgt,bev_btm=0,bev_top=0,trans_arr=[[0,0,0]]) {
    translate([0,0,base_floor_skin_thk]) cylinder_bev_stud(rad,-base_floor_skin_thk+hgt,bev_btm,bev_top,trans_arr);
}

module feature_screws(part,operation) {
    screw_len = 8;

    for(it=case_crn_trans) {
        bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

        boss_crn_trans = vec_to_array(it,4)+xyz_to_trans([1,1,0]*10,ident_xyz(sign(it.x),sign(it.y),0));

        if(part == part_base) {
            // if(operation == operation_union) translate([0,0,base_floor_skin_thk]) cylinder_bev_stud(1.25+w6,-base_floor_skin_thk+base_hgt,bev_m,bev_m,boss_crn_trans);

            if(operation == operation_union) intersection() {
                cylinder_bev(1.25+w6,base_hgt,0,bev_m,boss_crn_trans);

                translate(it+[0,0,base_hgt-(screw_len-2)]) rotate([0,0,atan2(sign(it.y),sign(it.x))]) translate(-[1.25+w6,0,0]) rotate([0,52.5,0]) translate(-[1,1,0]*50) cube([2,2,2]*50);
            }

            if(operation == operation_difference) translate([0,0,base_hgt]) {
                cylinder_bev_co_blind_downwards(1.25,screw_len-2,0.5,bev_m,0,[it]);
            }
        }

        if(part == part_tray) {
            if(operation == operation_difference) translate([0,0,tray_z]) cylinder_bev_co_through(1.25+w6,tray_hgt,bev_m,bev_m,clr_loose,boss_crn_trans);
        }

        if(part == part_top) translate([0,0,base_hgt]) {
            if(operation == operation_difference) {
                cylinder_bev_co_through(1.5,2,bev_m,bev_s,clr_close,[it]);
                translate([0,0,top_hgt]) cylinder_bev_co_blind_downwards(3,top_hgt-2,bev_s,bev_m,clr_close,[it]);
            }

            if(operation == operation_placeholder) translate(it+[0,0,2]) material_stainless_steel() screw_m3_torx_placeholder(screw_len);
        }
    }
}

tray_screw_offsets
    = [[-1],[0],[0],[0]]*[[4,0,0]]
    + [[0],[1],[0],[0]]*[[2,0,0]]
    + [[0],[0],[1],[1]]*[battery_position*ident_xyz(1,0,0)];

module feature_tray_screws(part,operation) {
    tray_screw_trans = xyz_to_trans(case_dim/2-[0,1,0]*(w6+max(clr_free+3,clr_close+w6+1.5))-[1,0,0]*16)+tray_screw_offsets;

    screw_len = 8;

    for(it=tray_screw_trans) {
        bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

        boss_crn_trans = vec_to_array(it,2)+list_y_to_vec([0,10]*sign(it.y));

        if(part == part_base) {
            if(operation == operation_union) base_boss_cylinder_bev(1.25+w6,tray_z,bev_m,bev_m,boss_crn_trans);
            if(operation == operation_difference) translate([0,0,tray_z]) cylinder_bev_co_blind_downwards(1.25,screw_len-2,0.5,bev_m,0,[it]);
        }

        if(part == part_tray) translate([0,0,tray_z]) {
            recess_crn_trans = vec_to_array(it,3)+[[0,0,0],[0,1,0],[tan(45),1,0]]*20*ident_xyz(sign(it.x),sign(it.y),0);

            if(operation == operation_difference) {
                cylinder_bev_co_through(1.5,2,bev_m,bev_s,clr_close,[it]);
                translate([0,0,tray_hgt]) cylinder_bev_co_blind_downwards(3,tray_hgt-2,bev_s,bev_m,clr_close,recess_crn_trans);
            }
            if(operation == operation_placeholder) translate(it+[0,0,2]) material_stainless_steel() screw_m3_torx_placeholder(screw_len);
        }
    }

    if(part == part_tray && operation == operation_union_nonintersect) translate([0,0,tray_z]) {
        cylinder_bev(1.5+clr_close+w6,2,bev_m,bev_s,tray_screw_trans);
    }
}

module feature_feet(part,operation) {
    base_feet_trans = xyz_to_trans(case_dim/2)-outset_to_trans(w6+2+3.8/2)-outset_xxyy_to_trans(1,1,0,0)*17+tray_screw_offsets;

    for(it=base_feet_trans) {
        bom_item(part,operation,str("FC-040 Rubber foot"));

        if(part == part_base) {
            boss_crn_trans = vec_to_array(it,2)+list_y_to_vec([0,10]*sign(it.y));
            
            if(operation == operation_union) base_boss_cylinder_bev(3.8/2+clr_tight+w6,2,bev_m,bev_m,boss_crn_trans);
            if(operation == operation_difference) cylinder_bev_co_through(3.8/2,2,bev_m,bev_m,clr_tight,[it]);

            if(operation == operation_placeholder) translate(it) fc040_foot_placeholder();
        }
    }
}

magnet_r = 8/2;
magnet_h = 3;

magnet_trans = xyz_to_trans([case_dim.x/2-w6-1,w6/2,0]+[-1,1,0]*(magnet_r+clr_close));

module feature_magnets(part,operation) {
    boss_hgt = 0.4+2*magnet_h;

    for(it=magnet_trans) {
        bom_item(part,operation,str(magnet_r*2,"mm x ",magnet_h,"mm neodymium magnet"));

        if(part == part_base) {
            boss_crn_trans = vec_to_array(it,4)+xyz_to_trans([1,0,0]*10+[0,abs(it.y/2),0],ident_xyz(sign(it.x),-sign(it.y),0));
            
            if(operation == operation_union) {
                base_boss_cylinder_bev(magnet_r+clr_close+w6,boss_hgt,bev_m,bev_m,boss_crn_trans);
            }
            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                cylinder_bev_co_blind_downwards(magnet_r,magnet_h+1,1,bev_m,clr_close,[it]);

                translate(it) let(rad=4,hgt=boss_hgt-0.4,bev_btm=bev_s,bev_top=bev_m) intersection() {
                    cylinder_bev_co_blind_downwards(magnet_r,boss_hgt-0.4,bev_s,bev_m,clr_close);

                    intersection_for(i=[0:3-1]) rotate([0,0,360/3*i]) translate([magnet_r-clr_close+rad,0,-hgt]) rotate_extrude() polygon([
                        [50,-0.01],
                        [rad+bev_btm,-0.01],
                        [rad,bev_btm],
                        [rad,hgt-bev_top],
                        [rad-bev_top,hgt+0.01],
                        [50,hgt+0.01],
                    ]);
                }
            }

            if(operation == operation_placeholder) translate(it+[0,0,boss_hgt]) {
                material_nickel() translate([0,0,-1]*magnet_h) cylinder_bev_rad(magnet_r,magnet_h,0.5,0.5);
                material_nickel() translate([0,0,-2]*magnet_h) cylinder_bev_rad(magnet_r,magnet_h,0.5,0.5);
            }
        }
    }
}

module feature_cable_gland(part,operation) {
    boss_wid = 20;
    boss_y_inset = 20;

    boss_crn_r = 4;
    boss_crn_trans = wing_crn_trans+outset_to_trans(case_crn_r-boss_crn_r)+outset_xxyy_to_trans(case_crn_r+4-wing_wid,boss_wid,-boss_y_inset,0);

    boss_hgt = base_hgt+top_hgt-8;

    boss_fillet_r = 2;

    cable_gland_pos = case_dim/2*ident_xyz(1,-1,0)+[wing_wid+clr_close+boss_wid/2,boss_y_inset,boss_hgt/2];

    if(part == part_base) {
        if(operation == operation_union_nonintersect) {
            cylinder_bev(boss_crn_r,boss_hgt,bev_m,bev_m,boss_crn_trans);

            translate(case_dim/2*ident_xyz(1,-1,0)+[wing_wid+clr_close,0,0]+[0,boss_y_inset,0]) let(crn_r=boss_fillet_r,hgt=boss_hgt,bev_btm=bev_m,bev_top=bev_m) rotate([0,0,90]) translate(-[1,1,0]*crn_r) rotate_extrude(angle=90) polygon([
                [crn_r+5,-0.01],
                [crn_r+bev_btm,-0.01],
                [crn_r,bev_btm],
                [crn_r,hgt-bev_top],
                [crn_r+bev_top,hgt+0.01],
                [crn_r+5,hgt+0.01],
            ]);

            intersection() {
                union() {
                    cylinder_bev(boss_crn_r,boss_hgt+bev_m,bev_m,bev_m,boss_crn_trans);

                    translate(case_dim/2*ident_xyz(1,-1,0)+[wing_wid+clr_close,0,0]+[0,boss_y_inset,0]) let(crn_r=boss_fillet_r,hgt=boss_hgt+bev_m,bev_btm=bev_m,bev_top=bev_m+bev_m) rotate([0,0,90]) translate(-[1,1,0]*crn_r) rotate_extrude(angle=90) polygon([
                        [crn_r+5,-0.01],
                        [crn_r+bev_btm,-0.01],
                        [crn_r,bev_btm],
                        [crn_r,hgt-bev_top],
                        [crn_r+bev_top,hgt+0.01],
                        [crn_r+5,hgt+0.01],
                    ]);
                }

                translate([0,0,boss_hgt-bev_m]) cylinder_bev_stud(case_crn_r,bev_m+bev_m,bev_m+bev_m,bev_m,wing_crn_trans);
            }
        }

        if(operation == operation_difference) {
            recess_y_inset = 6;
            recess_len = case_dim.y-boss_y_inset-recess_y_inset-2*w6;
            recess_crn_trans = vec_to_array(cable_gland_pos*ident_xyz(1,1,0)+[0,w6+recess_y_inset,0],4)+xyz_to_trans([boss_wid/2-w6,recess_len/2,0],attach_top)-outset_to_trans(4-w6);

            translate(cable_gland_pos) rotate([-90,0,0]) {
                cylinder_oh_bev_co_through(8/2,w6,bev_s,bev_s,clr_close);

                translate([0,0,w6+recess_y_inset]) {
                    cylinder_oh_bev_co_blind_downwards(0,recess_y_inset,0,bev_s,clr_close,points_reg_polygon_flat(6)*13/2);
                    cylinder_bev_rad(boss_wid/2-w6,recess_len,4-w6,4-w6);
                }
            }
            // cylinder_bev_co_blind_upwards(4-w6,cable_gland_pos.z,bev_m,0,0,recess_crn_trans);
            cylinder_bev_co_through(0.5,1,bev_m,bev_s,0,recess_crn_trans-outset_to_trans(0.5));
            translate([0,0,1]) cylinder_bev(4-w6,-1+cable_gland_pos.z,bev_m,0,recess_crn_trans);

            // cylinder_bev_co_through(boss_crn_r-w6,base_hgt+top_hgt-,bev_m,bev_m,boss_crn_trans);
        }
    }
}

probe_slot_dep = 4;
probe_slot_clr = clr_loose;

module feature_probe_slot(part,operation) {
    probe_pos = [case_dim.x/2+clr_close+wing_wid/2,0,base_hgt+top_hgt];

    bev_top = 1;

    slot_r1 = 10/cos(30)/2;

    if(part == part_base && operation == operation_difference) {
        translate(probe_pos) {
            translate([0,-11/2,0]) slot_co_bev(slot_r1,11);
            translate([0,11/2,0]) slot_co_bev_upwards(8/2,8);
            translate([0,11/2+8,0]) slot_co_bev_upwards(5/2,100);

            translate([0,-11/2,0]) mirror([0,1,0]) slot_co_bev_upwards(9.3/2,100);
        }
        translate(probe_pos*ident_xyz(1,1,0)) {
            cylinder_bev_co_blind_upwards(12/2,base_hgt+top_hgt-probe_slot_dep-slot_r1-probe_slot_clr-0.6,bev_m,0);
        }
    }
}

module slot_co_bev(co_wid,co_len) {
    slot_clr = probe_slot_clr;

    // cylinder_bev_co_blind_downwards(0,probe_slot_dep,0,bev_top,slot_clr,xyz_to_trans([10/cos(30)/2,11/2,0]));

    rotate([-90,0,0]) translate([0,0,-slot_clr]) cylinder_bev_rad(co_wid+slot_clr,co_len+2*slot_clr,slot_clr,slot_clr,list_y_to_vec([0,probe_slot_dep]));
}

module slot_co_bev_upwards(co_wid,co_len) {
    slot_clr = probe_slot_clr;

    // cylinder_bev_co_blind_downwards(0,probe_slot_dep,0,bev_top,slot_clr,xyz_to_trans([10/cos(30)/2,11/2,0]));

    rotate([-90,0,0]) translate([0,0,slot_clr]) cylinder_bev_rad_co_blind_upwards(co_wid+slot_clr,co_len,slot_clr,slot_clr,0,list_y_to_vec([0,probe_slot_dep]));
}

module feature_battery_18650(part,operation,position=[0,0,0],feature_attach=attach_bottom,feature_rotate=0) {
    feature_battery(part,operation,position,feature_attach,feature_rotate,battery_18650_r,battery_18650_hgt);
}

module feature_battery_21700(part,operation,position=[0,0,0],feature_attach=attach_bottom,feature_rotate=0) {
    feature_battery(part,operation,position,feature_attach,feature_rotate,battery_21700_r,battery_21700_hgt);
}

module feature_battery(part,operation,position=[0,0,0],feature_attach=attach_bottom,feature_rotate=0,battery_r=battery_18650_r,battery_hgt=battery_18650_hgt) {
    depth_in_face = 0;

    clr_battery = clr_free;
    clr_battery_axial = clr_battery+1;

    boss_hgt = base_hgt;
    terminal_boss_hgt = depth_in_face+boss_hgt-max(7,battery_r+clr_battery+6.6);

    battery_center_dep = -depth_in_face+battery_r+clr_battery;

    terminal_dim = [5,13.5,0];
    terminal_clr_dim = terminal_dim+[0,-7.5,0];

    terminal_screw_trans = list_y_to_vec([-1,1]*(battery_hgt/2+terminal_dim.y-2.8));

    pcb_dim = ([battery_r,battery_hgt/2+clr_battery_axial-clr_battery,0]*2+[1,1,0]*(clr_battery+w6))*rotation_matrix(-feature_rotate);

    translate(position+(pcb_dim/2+[1,1,0]*(w6))*feature_attach) rotate([0,0,feature_rotate]) {
        if(part == part_base) {
            if(operation == operation_union) {
                difference() {
                    union() {
                        base_boss_cylinder_bev(clr_battery+w6,boss_hgt,bev_m,bev_m,xyz_to_trans([battery_r,battery_hgt/2+clr_battery_axial-clr_battery,0]));
                    }
                    cylinder_bev_co_through(0,boss_hgt,0,bev_m,clr_battery,xyz_to_trans([0,battery_hgt/2+clr_battery_axial-clr_battery,0]+[(battery_r+clr_battery)*sin(30),0,0]));
                }
                
                difference() {
                    union() {
                        base_boss_cylinder_bev(clr_close+w6,boss_hgt,bev_m,bev_m,xyz_to_trans([terminal_clr_dim.x/2,battery_hgt/2,0]+[0,terminal_clr_dim.y,0]));
                        base_boss_cylinder_bev(1.25+w6,terminal_boss_hgt,bev_m,bev_m,terminal_screw_trans);
                    }

                    for(it=terminal_screw_trans) translate(it+[0,0,terminal_boss_hgt]) {
                        //clearance for screw and crimp terminal
                        cylinder_bev(4+clr_close,4+4,bev_s,4);
                    }
                    cylinder_bev_co_through(0,boss_hgt,0,bev_m,clr_battery,xyz_to_trans([0,battery_hgt/2+clr_battery_axial-clr_battery,0]+[(battery_r+clr_battery)*sin(30),0,0]));
                }
            }
            
            if(operation == operation_difference) {
                translate([0,0,boss_hgt]) cylinder_bev_co_blind_downwards(0,battery_center_dep,0,bev_m,clr_battery,xyz_to_trans([battery_r,battery_hgt/2+clr_battery_axial-clr_battery,0]));

                translate([0,0,boss_hgt-battery_center_dep]) rotate([-90,0,0]) translate([0,0,-battery_hgt/2-clr_battery_axial]) cylinder_bev_rad(battery_r+clr_battery,battery_hgt+2*clr_battery_axial,clr_battery,clr_battery);

                cylinder_bev_co_through(0,boss_hgt,bev_m,bev_m,clr_battery,xyz_to_trans([0,battery_hgt/2+clr_battery_axial-clr_battery,0]+[(battery_r+clr_battery)*sin(30),0,0]));

                translate([0,0,boss_hgt]) cylinder_bev_co_blind_downwards(0,boss_hgt-terminal_boss_hgt,min(bev_s,clr_close),bev_m,clr_close,xyz_to_trans([terminal_clr_dim.x/2,battery_hgt/2+terminal_clr_dim.y,0]));

                translate([0,0,terminal_boss_hgt]) cylinder_bev(clr_close,8,min(bev_s,clr_close),min(bev_s,clr_close),xyz_to_trans([terminal_clr_dim.x/2,battery_hgt/2+terminal_dim.y-2.8,0]));

                reflect_y() reflect_x() translate(-[terminal_dim.x/2+clr_close,battery_hgt/2+clr_battery_axial,0]+[-1,-1,0]+[0,0,terminal_boss_hgt]) rotate_extrude(angle=90) polygon([
                    [4,-0.01],
                    [1+bev_s,-0.01],
                    [1,bev_s],
                    [1,boss_hgt-terminal_boss_hgt-bev_m],
                    [1-bev_m,boss_hgt-terminal_boss_hgt+0.01],
                    [4,boss_hgt-terminal_boss_hgt+0.01],
                ]);
            }

            if(operation == operation_placeholder) {
                translate([0,0,boss_hgt-battery_center_dep]) rotate([90,0,0]) battery_placeholder(battery_r,battery_hgt);
            }
        }

        for(it=terminal_screw_trans) {
            bom_item(part,operation,str("5231 battery spring contact"));
            let(screw_len=6) bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

            if(part == part_base) translate(it) {
                if(operation == operation_difference) {
                    if(terminal_boss_hgt >= 8+0.8) {
                        translate([0,0,terminal_boss_hgt])cylinder_bev_co_blind_downwards(1.25,8,0.5,bev_m);
                    } else {
                        cylinder_bev_co_through(1.25,terminal_boss_hgt,bev_m,bev_m);
                    }

                    translate([0,0,terminal_boss_hgt]) {
                        //clearance for screw and crimp terminal
                        cylinder_bev(3+clr_close,4+3,bev_s,3);
                        //clearance for contact spring
                        cylinder_bev(clr_close,4,min(bev_s,clr_close),min(bev_s,clr_close),xyz_to_trans([terminal_dim.x,2.8,0]/2,ident_xyz(0,sign(it.y),0)));
                    }
                }

                if(operation == operation_placeholder) translate([0,0,terminal_boss_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }

        if(part == part_tray && operation == operation_difference) translate([0,0,tray_z]) {
            cylinder_bev_co_through(clr_free+w6,tray_hgt,bev_m,bev_m,clr_loose,xyz_to_trans([battery_r,battery_hgt/2+clr_battery_axial-clr_battery,0]));

            cylinder_bev_co_through(clr_free+w6,tray_hgt,bev_m,bev_m,clr_loose,xyz_to_trans([terminal_clr_dim.x/2,battery_hgt/2,0]+[0,terminal_clr_dim.y,0]));

            if(terminal_boss_hgt+4 > tray_z + 1) cylinder_bev_co_through(max(1.25+w6,3),terminal_boss_hgt+4-tray_z,bev_m,0,clr_loose,terminal_screw_trans);
        }
    }
}

module feature_position(position,feature_attach,feature_rotate,feature_dim) {
    translate(position+(feature_dim/2+[1,1,0]*(w6+clr_pcb))*feature_attach) rotate([0,0,feature_rotate]) children();
}

module feature_esp32_variant(part,operation,position,feature_attach,feature_rotate,boss_hgt,pcb_dim,pcb_crn_r,pin_loc,top_component_trans,top_component_z) {
    feature_position(position,feature_attach,feature_rotate,pcb_dim) {
        if(part == part_base && operation == operation_union) {
            base_boss_cylinder_bev(4,boss_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2));
        }

        if(part == part_base && operation == operation_union_nonintersect) {
            translate([0,pcb_dim.y/2+clr_pcb+w6,boss_hgt+(base_hgt-boss_hgt)/2]) wall_symbol(wall_symbol_console);
        }

        if(part == part_base && operation == operation_difference) translate([0,0,boss_hgt]) {
            usbc_module_intersect(pcb_dim,clr_pcb) {
                component_pcb_co(pcb_dim,pcb_crn_r);
                for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));

                component_btm_component_co([for(i=[0:len(top_component_trans)-1]) top_component_trans[i]*ident_xyz(-1,1,0)],[for(i=[0:len(top_component_z)-1]) top_component_z[i]+pcb_dim.z],boss_hgt);
            }
            usbc_module_flipped_port_intersect(pcb_dim,clr_pcb) {
                translate([0,0,-pcb_dim.z]) mirror([0,0,1]) usbc_wall_co(pcb_dim,clr_pcb,w6,0);
            }
        }

        feature_screw_trans = [[0,-1,0]*(pcb_dim.y/2+clr_pcb+clr_close+1.5)];

        for(it=feature_screw_trans) {
            let(screw_len=6) bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));
            
            if(part == part_base) {
                if(operation == operation_union) {
                    base_boss_cylinder_bev(1.5+clr_close+w6,boss_hgt,bev_m,bev_m,[it]);
                }
                if(operation == operation_difference) {
                    cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m,0,[it]);
                    translate([0,0,boss_hgt]) cylinder_bev_co_blind_downwards(1.5,pcb_dim.z,1.5+clr_close-1.25,bev_m,clr_close,vec_to_array(it,2)+list_y_to_vec([0,5]));

                    translate([0,0,boss_hgt]) cylinder_bev(3+clr_close,4+2,bev_m,2,[it]);
                }
                if(operation == operation_placeholder) translate(it+[0,0,boss_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }

        if(part == part_tray && operation == operation_difference) translate([0,0,tray_z]) {
            cylinder_bev_co_through(2,tray_hgt,bev_m,bev_m,0,xyz_to_trans(pcb_dim/2));
        }
    }
}

module feature_esp32c3_supermini(part,operation,position=[0,0,0],feature_attach=attach_top,feature_rotate=0,boss_hgt=6) {
    pcb_dim = esp32c3_supermini_pcb_dim;
    pcb_crn_r = esp32c3_supermini_pcb_crn_r;
    pin_loc = esp32c3_supermini_pin_loc;
    screw_trans = [];
    top_component_trans = esp32c3_supermini_top_component_trans;
    top_component_z = esp32c3_supermini_top_component_z;

    bom_item(part,operation,str("ESP32 C3 supermini MCU"));

    feature_esp32_variant(part,operation,position,feature_attach,feature_rotate,boss_hgt,pcb_dim,pcb_crn_r,pin_loc,top_component_trans,top_component_z);

    feature_position(position,feature_attach,feature_rotate,pcb_dim) {
        if(part == part_base && operation == operation_difference) {
            translate([-5.4/2,-pcb_dim.y/2+14.1,0]) {
                cylinder_bev_co_through(min(1.25,5.4/2-w6/2),boss_hgt,bev_m,bev_m+pcb_dim.z,0);
                // translate([-7,0,0]) difference() {
                //     cylinder_bev_co_blind_upwards(1,0.4,0.01,0,0,xyz_to_trans([3,4.2,0])-outset_to_trans(1));
                //     translate([0.2,0,0]) linear_extrude(height=10) mirror([1,0,0]) font_comfortaa_bold("R",w2,"center","center");
                // }
            }
            translate([5.4/2,-pcb_dim.y/2+14.1,0]) {
                cylinder_bev_co_through(0.5,boss_hgt,bev_m,bev_m+pcb_dim.z,0,xyz_to_trans([1,1,0]*min(1.25,5.4/2-w6/2))-outset_to_trans(0.5));
                // translate([7,0,0]) difference() {
                //     cylinder_bev_co_blind_upwards(1,0.4,0.01,0,0,xyz_to_trans([3,4.2,0])-outset_to_trans(1));
                //     linear_extrude(height=10) mirror([1,0,0]) font_comfortaa_bold("B",w2,"center","center");
                // }
            }
        }

        if(part == part_base && operation == operation_placeholder) translate([0,0,tray_hgt]) {
            translate([0,0,-pcb_dim.z]) rotate([0,180,0]) esp32c3_supermini_placeholder();

            // material_pcb_black() component_placeholder(pcb_dim,pcb_crn_r,screw_trans,[],[],[],false);
            // material_plastic_black() if(len(max6675_top_component_trans)>0) for(cutout_i=[0:len(max6675_top_component_trans)-1]) cylinder_bev_co_blind_upwards(0.01,max6675_top_component_z[cutout_i],0,0,clr_component,max6675_top_component_trans[cutout_i]);
            // for(it=list_partial(pin_loc,0,2)) translate(it) rotate([0,0,180]) pin_header_right_angle_placeholder() dupont_header_placeholder();
        }
    }
}


module feature_esp32c3_superminiplus(part,operation,position=[0,0,0],feature_attach=attach_top,feature_rotate=0,boss_hgt=6) {
    pcb_dim = esp32c3_supermini_pcb_dim;
    pcb_crn_r = esp32c3_supermini_pcb_crn_r;
    pin_loc = esp32c3_supermini_pin_loc;
    top_component_trans = esp32c3_supermini_top_component_trans;
    top_component_z = esp32c3_supermini_top_component_z;

    bom_item(part,operation,str("ESP32 C3 supermini plus MCU"));

    feature_esp32_variant(part,operation,position,feature_attach,feature_rotate,boss_hgt,pcb_dim,pcb_crn_r,pin_loc,top_component_trans,top_component_z);
}

module feature_esp32s3_supermini(part,operation,position=[0,0,0],feature_attach=attach_top,feature_rotate=0,boss_hgt=6) {
    pcb_dim = esp32s3_supermini_pcb_dim;
    pcb_crn_r = esp32s3_supermini_pcb_crn_r;
    pin_loc = esp32s3_supermini_pin_loc;
    top_component_trans = esp32s3_supermini_top_component_trans;
    top_component_z = esp32s3_supermini_top_component_z;

    bom_item(part,operation,str("ESP32 S3 supermini MCU"));

    feature_esp32_variant(part,operation,position,feature_attach,feature_rotate,boss_hgt,pcb_dim,pcb_crn_r,pin_loc,top_component_trans,top_component_z);
}

module feature_bms(part,operation,position=[0,0,0],feature_attach=attach_top,feature_rotate=0,boss_hgt=6) {
    pcb_dim = lxlbc3_pcb_dim;
    pcb_crn_r = lxlbc3_pcb_crn_r;
    pin_loc = lxlbc3_pin_loc;
    screw_trans = [];
    top_component_trans = lxlbc3_top_component_trans;
    top_component_z = lxlbc3_top_component_z;

    bom_item(part,operation,str("LX-LBC 1S lithium ion BMS with USB-C charging and 5V boost"));

    feature_position(position,feature_attach,feature_rotate,pcb_dim) {
        if(part == part_base) {
            if(operation == operation_union) base_boss_cylinder_bev(4,boss_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2));

            if(operation == operation_union_nonintersect) translate([0,pcb_dim.y/2+clr_pcb+w6,boss_hgt+(base_hgt-boss_hgt)/2]) wall_symbol(wall_symbol_thunderbolt);

            if(operation == operation_difference) translate([0,0,boss_hgt]) {
                usbc_module_intersect(pcb_dim,clr_pcb) {
                    component_pcb_co(pcb_dim,pcb_crn_r);
                    for(it=pin_loc) component_co_downwards(2+pcb_dim.z,boss_hgt,pin_dupont_header_co_crn_trans(it));
                    component_btm_component_co([for(i=[0:len(top_component_trans)-1]) top_component_trans[i]*ident_xyz(-1,1,0)],[for(i=[0:len(top_component_z)-1]) top_component_z[i]+pcb_dim.z],boss_hgt);
                }
                usbc_module_flipped_port_intersect(pcb_dim,clr_pcb) {
                    translate([0,0,-pcb_dim.z]) mirror([0,0,1]) usbc_wall_co(pcb_dim,clr_pcb,w6,0);
                }
            }

            if(operation == operation_placeholder) translate([0,0,tray_hgt]) {
                translate([0,0,-pcb_dim.z]) rotate([0,180,0]) lxlbc3_placeholder();

                // material_pcb_black() component_placeholder(pcb_dim,pcb_crn_r,screw_trans,[],[],[],false);
                // material_plastic_black() if(len(max6675_top_component_trans)>0) for(cutout_i=[0:len(max6675_top_component_trans)-1]) cylinder_bev_co_blind_upwards(0.01,max6675_top_component_z[cutout_i],0,0,clr_component,max6675_top_component_trans[cutout_i]);
                // for(it=list_partial(pin_loc,0,2)) translate(it) rotate([0,0,180]) pin_header_right_angle_placeholder() dupont_header_placeholder();
            }
        }

        feature_screw_trans = vec_to_array([0,pcb_dim.y/2+clr_pcb-(3+clr_close),0],2)+list_x_to_vec([-1,1]*(pcb_dim.x/2+clr_pcb+clr_close+1.5));

        for(it=feature_screw_trans) {
            let(screw_len=6) bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

            if(part == part_base) {
                if(operation == operation_union) {
                    base_boss_cylinder_bev(1.5+clr_close+w6,boss_hgt,bev_m,bev_m,[it]);
                }
                if(operation == operation_difference) {
                    cylinder_bev_co_through(1.25,boss_hgt,bev_m,bev_m,0,[it]);
                    translate([0,0,boss_hgt]) cylinder_bev_co_blind_downwards(1.5,pcb_dim.z,1.5+clr_close-1.25,bev_m,clr_close,vec_to_array(it,2)+list_x_to_vec(-[0,5]*sign(it.x)));
                    translate([0,0,boss_hgt]) cylinder_bev(3+clr_close,4+2,bev_m,2,[it]);
                }
                if(operation == operation_placeholder) translate(it+[0,0,boss_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }

        if(part == part_tray && operation == operation_difference) translate([0,0,tray_z]) {
            cylinder_bev_co_through(2,tray_hgt,bev_m,bev_m,0,xyz_to_trans(pcb_dim/2));
        }
    }
}

module feature_max6675(part,operation,position=[0,0,0],feature_attach,feature_rotate=0,boss_hgt=6) {
    pcb_dim = max6675_pcb_dim;
    pcb_crn_r = max6675_pcb_crn_r;
    pin_loc = max6675_pin_loc;
    screw_trans = max6675_screw_trans;
    top_component_trans = max6675_top_component_trans;
    top_component_z = max6675_top_component_z;

    bom_item(part,operation,str("MAX6675 thermocouple to SPI module"));

    feature_position(position,feature_attach,feature_rotate,pcb_dim) {
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_union_nonintersect) {
                cylinder_bev(clr_pcb+w6,tray_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2));
            }
            if(operation == operation_difference) translate([0,0,tray_hgt]) {
                component_pcb_co(pcb_dim,pcb_crn_r);

                for(it=pin_loc) component_co_downwards(tray_hgt,tray_hgt,pin_dupont_header_co_crn_trans(it));

                component_btm_component_co([for(i=[0:len(top_component_trans)-1]) top_component_trans[i]*ident_xyz(-1,1,0)],[for(i=[0:len(top_component_z)-1]) top_component_z[i]+pcb_dim.z],tray_hgt);
            }

            if(operation == operation_placeholder) translate([0,0,tray_hgt]) {
                material_pcb_black() component_placeholder(max6675_pcb_dim,max6675_pcb_crn_r,max6675_screw_trans,[],[],[],false);
                // material_plastic_black() if(len(max6675_top_component_trans)>0) for(cutout_i=[0:len(max6675_top_component_trans)-1]) cylinder_bev_co_blind_upwards(0.01,max6675_top_component_z[cutout_i],0,0,clr_component,max6675_top_component_trans[cutout_i]);
                for(it=list_partial(pin_loc,0,4)) translate(it) rotate([0,0,180]) pin_header_right_angle_placeholder() dupont_header_placeholder();
            }
        }

        for(it=screw_trans) {
            let(screw_len=6) bom_item(part,operation,str("M3 x ",screw_len,"mm self-tapping flat-end plastic screw"));

            if(part == part_tray) translate([0,0,tray_z]) {
                if(operation == operation_difference) cylinder_bev_co_through(1.25,tray_hgt,bev_m,bev_m+pcb_dim.z,0,[it]);
                if(operation == operation_placeholder) translate(it+[0,0,tray_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }
    }
}

module feature_max7219_display(part,operation,position=[0,0,0],feature_attach=attach_top,feature_rotate=0) {
    feature_position(position,feature_attach,feature_rotate,max7219_display_pcb_dim) {
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_difference) translate([0,0,tray_hgt]) {
                component_pcb_co(max7219_display_pcb_dim,max7219_display_pcb_crn_r);
                for(it=max7219_display_pin_loc) component_co_downwards(2+max7219_display_pcb_dim.z,tray_hgt,pin_dupont_header_co_crn_trans(it));
                component_btm_component_co(max7219_btm_component_trans,max7219_btm_component_z,tray_hgt);

                translate([0,0,-tray_hgt]) cylinder_bev_co_through(2,tray_hgt-max7219_display_pcb_dim.z,bev_m,bev_m,0,xyz_to_trans(max7219_display_pcb_dim/2)-outset_to_trans(2)-outset_xxyy_to_trans(8,8,1,1));
            }

            for(it=max7219_display_screw_trans) {
                if(operation == operation_difference) cylinder_bev_co_through(1.25,tray_hgt,bev_m,bev_m+max7219_display_pcb_dim.z,0,[it]);
                if(operation == operation_placeholder) translate(it+[0,0,tray_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }

            if(operation == operation_placeholder) translate([0,0,tray_hgt]) {
                max7219_display_placeholder();

                // for(it=list_partial(max7219_display_pin_loc,5,10-1)) translate(it) {
                //     rotate([0,0,90]) pin_header_right_angle_placeholder() dupont_header_placeholder();
                // }

                // for(it=list_partial(max7219_display_pin_loc,0,5-1)) translate(it+[0,0,-max7219_display_pcb_dim.z]) pin_header_placeholder_downwards() dupont_header_placeholder();
            }
        }

        if(part == part_top && operation == operation_difference) translate([0,0,base_hgt]) {
            cylinder_bev_co_through(max7219_display_crn_r,top_hgt-1,bev_m,bev_m,clr_close,max7219_display_crn_trans);

            translate([0,0,top_hgt]) cylinder_bev_co_blind_downwards(max7219_display_crn_r+2,1,bev_m,bev_m,clr_close,max7219_display_crn_trans-outset_to_trans(2)+outset_xxyy_to_trans(8,8,16,4));
        }
    }
}

module feature_buzzer(part,operation,position=[0,0,0],feature_attach,feature_rotate=0,boss_hgt=6) {
    pcb_dim = mhfmd_buzzer_pcb_dim;
    pcb_crn_r = mhfmd_buzzer_pcb_crn_r;
    pin_loc = mhfmd_buzzer_pin_loc;
    screw_trans = mhfmd_buzzer_screw_trans;
    top_component_trans = mhfmd_buzzer_top_component_trans;
    top_component_z = mhfmd_buzzer_top_component_z;

    feature_position(position,feature_attach,feature_rotate,pcb_dim) {
        if(part == part_tray) translate([0,0,tray_z]) {
            if(operation == operation_union_nonintersect) {
                cylinder_bev(clr_pcb+w6,tray_hgt,bev_m,bev_m,xyz_to_trans(pcb_dim/2));
            }

            if(operation == operation_difference) translate([0,0,tray_hgt]) {
                component_pcb_co(pcb_dim,pcb_crn_r);
                for(it=pin_loc) component_co_downwards(2+pcb_dim.z,tray_hgt,pin_dupont_header_co_crn_trans(it));
            }

            if(operation == operation_placeholder) translate([0,0,tray_hgt]) {
                material_pcb_black() component_placeholder(pcb_dim,pcb_crn_r,screw_trans,[],[],[],false);
                // material_plastic_black() if(len(max6675_top_component_trans)>0) for(cutout_i=[0:len(max6675_top_component_trans)-1]) cylinder_bev_co_blind_upwards(0.01,max6675_top_component_z[cutout_i],0,0,clr_component,max6675_top_component_trans[cutout_i]);
                for(it=list_partial(pin_loc,0,2)) translate(it) rotate([0,0,180]) pin_header_right_angle_placeholder() dupont_header_placeholder();
            }

            for(it=screw_trans) {
                if(operation == operation_difference) cylinder_bev_co_through(1.25,tray_hgt,bev_m,bev_m+pcb_dim.z,0,[it]);
                if(operation == operation_placeholder) translate(it+[0,0,tray_hgt]) material_stainless_steel() screw_m3_torx_placeholder(6);
            }
        }
    }
}