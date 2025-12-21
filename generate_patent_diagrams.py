#!/usr/bin/env python3
"""
Patent Diagram Generator for Pathfinder Indoor Navigation System
Generates professional technical diagrams suitable for patent applications
Classic patent-style black and white line drawings
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Rectangle, FancyBboxPatch
import numpy as np

# Set up classic patent styling - black and white only
plt.style.use('default')
plt.rcParams['font.family'] = 'Arial'
plt.rcParams['font.size'] = 11
plt.rcParams['font.weight'] = 'normal'

def create_system_architecture():
    """Generate Figure 1: System Architecture Overview - Simplified Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 9.6, 7.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 9.2, 7.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 7.2, 'PATHFINDER SYSTEM ARCHITECTURE', 
            ha='center', va='center', fontsize=18, fontweight='bold')
    
    # Top Row: Navigation Modules
    # Module 1: ONM (Outdoor Navigation Module)
    onm_box = Rectangle((0.8, 5.5), 1.8, 1, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(onm_box)
    ax.text(1.7, 6.2, 'ONM', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(1.7, 5.8, 'Outdoor Navigation', ha='center', va='center', fontsize=9)
    
    # Module 2: ARNM (AR Navigation Module)
    arnm_box = Rectangle((2.8, 5.5), 1.8, 1, linewidth=2, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(arnm_box)
    ax.text(3.7, 6.2, 'ARNM', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(3.7, 5.8, 'AR Navigation', ha='center', va='center', fontsize=9)
    
    # Module 3: AMTCM (Transition Controller)
    amtcm_box = Rectangle((4.8, 5.5), 1.8, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(amtcm_box)
    ax.text(5.7, 6.2, 'AMTCM', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(5.7, 5.8, 'Transition Control', ha='center', va='center', fontsize=9)
    
    # Module 4: INM (Indoor Navigation Module)
    inm_box = Rectangle((6.8, 5.5), 1.8, 1, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(inm_box)
    ax.text(7.7, 6.2, 'INM', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(7.7, 5.8, 'Indoor Navigation', ha='center', va='center', fontsize=9)
    
    # Bottom Row: Support Components
    # Module 5: DPU (Data Processing Unit) - aligned under INM
    dpu_box = Rectangle((6.8, 3.5), 1.8, 1, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(dpu_box)
    ax.text(7.7, 4.2, 'DPU', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(7.7, 3.8, 'Data Processing', ha='center', va='center', fontsize=9)
    
    # User Interface - aligned under ONM/ARNM
    ui_box = Rectangle((1.3, 3.5), 2.8, 1, linewidth=2, 
                      edgecolor='black', facecolor='white')
    ax.add_patch(ui_box)
    ax.text(2.7, 4.2, 'USER INTERFACE', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(2.7, 3.8, '2D Map | AR Camera', ha='center', va='center', fontsize=9)
    
    # Horizontal arrows (left to right flow - NO CROSSING)
    # ONM to ARNM
    ax.annotate('', xy=(2.8, 6.0), xytext=(2.6, 6.0), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # ARNM to AMTCM
    ax.annotate('', xy=(4.8, 6.0), xytext=(4.6, 6.0), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # AMTCM to INM
    ax.annotate('', xy=(6.8, 6.0), xytext=(6.6, 6.0), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Vertical arrows (NO CROSSING)
    # DPU to INM (straight down)
    ax.annotate('', xy=(7.7, 5.5), xytext=(7.7, 4.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.text(8.2, 5.0, 'Graph\nData', ha='left', va='center', fontsize=8, style='italic')
    
    # ONM to UI (straight down)
    ax.annotate('', xy=(1.7, 4.5), xytext=(1.7, 5.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # ARNM to UI (straight down)
    ax.annotate('', xy=(3.7, 4.5), xytext=(3.7, 5.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Bottom legend
    ax.text(5, 2.5, 'Module Descriptions:', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(5, 2.1, 'ONM: Outdoor Navigation (Google Maps) | ARNM: AR Navigation (Camera, Outdoor Only)', 
            ha='center', va='center', fontsize=9)
    ax.text(5, 1.8, 'AMTCM: Autonomous Mode Transition (25m Threshold) | INM: Indoor Navigation (Dijkstra)', 
            ha='center', va='center', fontsize=9)
    ax.text(5, 1.5, 'DPU: Data Processing Unit (Python + OpenCV + NetworkX)', 
            ha='center', va='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('figure1_system_architecture.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure1_system_architecture.png")

def create_pathfinder_flow():
    """Generate Figure 2: Pathfinder Navigation Flow - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.3, 0.3), 9.4, 11.4, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.5, 0.5), 9, 11, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 11, 'PATHFINDER NAVIGATION FLOW', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Step 1: User Input
    step1_box = Rectangle((2, 9.5), 6, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step1_box)
    ax.text(5, 10, 'User Selects Destination (e.g., "G01")', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 9), xytext=(5, 9.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 2: Outdoor Navigation
    step2_box = Rectangle((1, 7.8), 8, 1.5, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step2_box)
    ax.text(5, 8.8, 'OUTDOOR NAVIGATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(5, 8.3, 'GPS + Google Maps to Building Entrance', 
            ha='center', va='center', fontsize=11)
    ax.text(5, 8.0, 'User can choose: 2D Map or AR Camera Mode', 
            ha='center', va='center', fontsize=10, style='italic')
    
    # Arrow down
    ax.annotate('', xy=(5, 7.3), xytext=(5, 7.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 3: Proximity Detection
    step3_box = Rectangle((2.5, 6.3), 5, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step3_box)
    ax.text(5, 6.8, 'Distance < 25m from Building?', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 5.8), xytext=(5, 6.3), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 4: Auto Switch
    step4_box = Rectangle((2, 4.8), 6, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step4_box)
    ax.text(5, 5.3, 'AUTOMATIC MODE SWITCH', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 4.3), xytext=(5, 4.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 5: Indoor Navigation
    step5_box = Rectangle((1, 2.3), 8, 2, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step5_box)
    ax.text(5, 3.8, 'INDOOR NAVIGATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(5, 3.3, '1. Load Building Graph (185 nodes, 282 edges)', 
            ha='center', va='center', fontsize=10)
    ax.text(5, 3.0, '2. Find Room "G01" in Graph', 
            ha='center', va='center', fontsize=10)
    ax.text(5, 2.7, '3. Calculate Optimal Path (Dijkstra Algorithm)', 
            ha='center', va='center', fontsize=10)
    ax.text(5, 2.4, '4. Display 2D Floor Plan with Path Overlay', 
            ha='center', va='center', fontsize=10)
    
    # Arrow down
    ax.annotate('', xy=(5, 1.8), xytext=(5, 2.3), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 6: Navigation Complete
    step6_box = Rectangle((2.5, 1.0), 5, 0.8, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step6_box)
    ax.text(5, 1.4, 'User Reaches Destination', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    # Add figure number
    ax.text(5, 0.8, 'Figure 2: Pathfinder Navigation Flow', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('figure2_pathfinder_flow.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure2_pathfinder_flow.png")

def create_graph_generation():
    """Generate Figure 3: Data Processing Unit - Simplified Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 9.6, 7.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 9.2, 7.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 7.2, 'DATA PROCESSING UNIT', 
            ha='center', va='center', fontsize=18, fontweight='bold')
    
    # Step 1: Floor Plan Input
    step1_box = Rectangle((1, 5.5), 8, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step1_box)
    ax.text(5, 6, 'STEP 1: FLOOR PLAN IMAGE INPUT (PNG/JPG)', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 5), xytext=(5, 5.5), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Step 2: Interactive Annotation
    step2_box = Rectangle((1, 4), 8, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step2_box)
    ax.text(5, 4.5, 'STEP 2: INTERACTIVE ANNOTATION (OpenCV + Click-Based)', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 3.5), xytext=(5, 4), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Step 3: Graph Generation
    step3_box = Rectangle((1, 2.5), 8, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step3_box)
    ax.text(5, 3, 'STEP 3: GRAPH GENERATION (NetworkX + Auto-Linking)', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 2), xytext=(5, 2.5), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Step 4: JSON Output
    step4_box = Rectangle((1, 1), 8, 1, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step4_box)
    ax.text(5, 1.5, 'STEP 4: JSON DATABASE OUTPUT (185 Nodes, 282 Edges)', 
            ha='center', va='center', fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('figure3_data_processing.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure3_data_processing.png")

def create_mode_transition():
    """Generate Figure 4: Pathfinder System Integration - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 11.6, 7.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 11.2, 7.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(6, 7.3, 'AUTONOMOUS MODE TRANSITION CONTROL MODULE', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Top - Pathfinder Application Framework (moved to top)
    mobile_box = Rectangle((2, 5.5), 8, 1.5, linewidth=2, 
                          edgecolor='black', facecolor='white')
    ax.add_patch(mobile_box)
    ax.text(6, 6.7, 'PATHFINDER APPLICATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # App components
    ax.text(3, 6.2, '• Location Services', ha='left', va='center', fontsize=9)
    ax.text(3, 5.9, '• Map Visualization', ha='left', va='center', fontsize=9)
    ax.text(6.5, 6.2, '• Path Calculation', ha='left', va='center', fontsize=9)
    ax.text(6.5, 5.9, '• User Interface', ha='left', va='center', fontsize=9)
    
    # Left side - Outdoor Navigation System (moved down)
    outdoor_box = Rectangle((0.8, 2.2), 3.5, 2.5, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outdoor_box)
    ax.text(2.55, 4.4, 'OUTDOOR NAVIGATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # GPS component
    gps_box = Rectangle((1, 3.5), 1.4, 0.6, linewidth=1, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(gps_box)
    ax.text(1.7, 3.8, 'GPS\nTracking', ha='center', va='center', fontsize=9)
    
    # Google Maps component
    maps_box = Rectangle((2.6, 3.5), 1.4, 0.6, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(maps_box)
    ax.text(3.3, 3.8, 'Google\nMaps API', ha='center', va='center', fontsize=9)
    
    # AR Mode component
    ar_box = Rectangle((1, 2.7), 3, 0.6, linewidth=1, 
                      edgecolor='black', facecolor='white')
    ax.add_patch(ar_box)
    ax.text(2.5, 3.0, 'AR Camera Mode (Optional)', ha='center', va='center', fontsize=9)
    
    # Center - Transition Controller (moved down)
    transition_box = Rectangle((5, 2.2), 2, 2.5, linewidth=3, 
                              edgecolor='black', facecolor='white')
    ax.add_patch(transition_box)
    ax.text(6, 4.2, 'TRANSITION', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(6, 3.9, 'CONTROLLER', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    
    # Proximity detection
    prox_box = Rectangle((5.2, 3.2), 1.6, 0.6, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(prox_box)
    ax.text(6, 3.5, 'Proximity\nDetection', ha='center', va='center', fontsize=9)
    
    # 25m threshold
    ax.text(6, 2.8, 'Distance < 25m', ha='center', va='center', fontsize=9, 
            style='italic')
    ax.text(6, 2.5, 'Auto Handoff', ha='center', va='center', fontsize=9, 
            fontweight='bold')
    
    # Right side - Indoor Navigation System (moved down)
    indoor_box = Rectangle((7.7, 2.2), 3.5, 2.5, linewidth=2, 
                          edgecolor='black', facecolor='white')
    ax.add_patch(indoor_box)
    ax.text(9.45, 4.4, 'INDOOR NAVIGATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Graph system
    graph_box = Rectangle((7.9, 3.5), 1.4, 0.6, linewidth=1, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(graph_box)
    ax.text(8.6, 3.8, 'Graph\nSystem', ha='center', va='center', fontsize=9)
    
    # Dijkstra algorithm
    dijkstra_box = Rectangle((9.5, 3.5), 1.4, 0.6, linewidth=1, 
                            edgecolor='black', facecolor='white')
    ax.add_patch(dijkstra_box)
    ax.text(10.2, 3.8, 'Dijkstra\nAlgorithm', ha='center', va='center', fontsize=9)
    
    # Node database
    node_box = Rectangle((7.9, 2.7), 3, 0.6, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(node_box)
    ax.text(9.4, 3.0, '185+ Nodes | JSON Database', ha='center', va='center', fontsize=9)
    
    # Data flow arrows
    # Outdoor to transition
    ax.annotate('', xy=(5, 3.4), xytext=(4.3, 3.4), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(4.65, 3.7, 'GPS\nData', ha='center', va='center', fontsize=8)
    
    # Transition to indoor
    ax.annotate('', xy=(7.7, 3.4), xytext=(7, 3.4), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(7.35, 3.7, 'Handoff\nTrigger', ha='center', va='center', fontsize=8)
    
    # Pathfinder app connections (arrows from app to modules)
    # Pathfinder App to Outdoor Navigation
    ax.annotate('', xy=(2.5, 4.7), xytext=(2.5, 5.5), 
                arrowprops=dict(arrowstyle='<->', lw=3, color='black', 
                               shrinkA=0, shrinkB=0))
    
    # Pathfinder App to Transition Controller  
    ax.annotate('', xy=(6, 4.7), xytext=(6, 5.5), 
                arrowprops=dict(arrowstyle='<->', lw=3, color='black',
                               shrinkA=0, shrinkB=0))
    
    # Pathfinder App to Indoor Navigation
    ax.annotate('', xy=(9.5, 4.7), xytext=(9.5, 5.5), 
                arrowprops=dict(arrowstyle='<->', lw=3, color='black',
                               shrinkA=0, shrinkB=0))
    
    # Bottom labels
    ax.text(6, 1.3, 'Seamless Outdoor-Indoor Navigation Integration', 
            ha='center', va='center', fontsize=11, style='italic')
    
    # Figure number text removed as requested
    
    plt.tight_layout()
    plt.savefig('figure4_system_integration.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure4_system_integration.png")

def create_indoor_navigation():
    """Generate Figure 5: Indoor Navigation Interface - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 12))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 9.6, 11.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 9.2, 11.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 11.4, 'INDOOR NAVIGATION SYSTEM INTERFACE', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Mobile Device Frame
    device_frame = Rectangle((1, 1.5), 8, 9.5, linewidth=3, 
                            edgecolor='black', facecolor='white')
    ax.add_patch(device_frame)
    
    # Screen Area
    screen_area = Rectangle((1.3, 1.8), 7.4, 8.9, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(screen_area)
    
    # Header Section
    header_section = Rectangle((1.5, 9.5), 7, 1, linewidth=2, 
                              edgecolor='black', facecolor='white')
    ax.add_patch(header_section)
    ax.text(5, 10, 'NAVIGATION CONTROL PANEL', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Input Section A: Start Location
    input_a = Rectangle((1.5, 8.5), 7, 0.8, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(input_a)
    ax.text(1.8, 9.1, 'START LOCATION INPUT', ha='left', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(1.8, 8.7, 'Selected: Entrance Node', ha='left', va='center', fontsize=9)
    
    # Input Section B: Destination Location  
    input_b = Rectangle((1.5, 7.5), 7, 0.8, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(input_b)
    ax.text(1.8, 8.1, 'DESTINATION INPUT', ha='left', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(1.8, 7.7, 'Selected: Room G01', ha='left', va='center', fontsize=9)
    
    # Main Display Area - Floor Plan Visualization
    display_area = Rectangle((1.5, 3.5), 7, 3.8, linewidth=2, 
                            edgecolor='black', facecolor='white')
    ax.add_patch(display_area)
    ax.text(5, 7.1, 'FLOOR PLAN DISPLAY MODULE', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    
    # Schematic Floor Plan Elements
    # Room representations (simplified rectangles)
    room_g01 = Rectangle((2, 6), 1.5, 0.8, linewidth=2, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(room_g01)
    ax.text(2.75, 6.4, 'G01', ha='center', va='center', fontsize=10, fontweight='bold')
    
    room_g02 = Rectangle((4, 6), 1.5, 0.8, linewidth=2, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(room_g02)
    ax.text(4.75, 6.4, 'G02', ha='center', va='center', fontsize=10)
    
    room_g03 = Rectangle((6, 6), 1.5, 0.8, linewidth=2, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(room_g03)
    ax.text(6.75, 6.4, 'G03', ha='center', va='center', fontsize=10)
    
    # Corridor/Pathway
    pathway = Rectangle((2, 5), 5.5, 0.8, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(pathway)
    ax.text(4.75, 5.4, 'NAVIGATION CORRIDOR', ha='center', va='center', fontsize=9)
    
    # Entrance Point
    entrance_point = Rectangle((2, 4), 1.5, 0.8, linewidth=2, 
                              edgecolor='black', facecolor='white')
    ax.add_patch(entrance_point)
    ax.text(2.75, 4.4, 'ENTRANCE', ha='center', va='center', fontsize=10, fontweight='bold')
    
    # Navigation Path (technical representation)
    # Path line from entrance through corridor to G01 (positioned to avoid text)
    ax.plot([2.75, 2.75, 2.75, 2.75], [4.8, 5.0, 5.8, 6.0], 
            'k--', linewidth=3)
    
    # Path markers (positioned at room edges to avoid text overlap)
    ax.plot([2.2], [4.8], 'ko', markersize=8)  # Start point (at entrance edge)
    ax.text(1.8, 4.8, 'START', ha='center', va='center', fontsize=8, fontweight='bold')
    
    ax.plot([2.2], [6.0], 'ks', markersize=8)  # End point (at G01 edge)
    ax.text(1.8, 6.0, 'TARGET', ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Add directional arrows along the path (in corridor area)
    ax.annotate('', xy=(2.75, 5.3), xytext=(2.75, 5.1), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.annotate('', xy=(2.75, 5.7), xytext=(2.75, 5.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Technical Specifications Panel
    specs_panel = Rectangle((1.5, 2.5), 7, 0.8, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(specs_panel)
    ax.text(5, 3.1, 'PATHFINDING ALGORITHM OUTPUT', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(5, 2.7, 'Path Length: 45.2m | Graph Nodes: 3 | Algorithm: Dijkstra', 
            ha='center', va='center', fontsize=9)
    
    # Control Interface
    control_panel = Rectangle((1.5, 1.9), 7, 0.5, linewidth=2, 
                             edgecolor='black', facecolor='white')
    ax.add_patch(control_panel)
    ax.text(5, 2.15, 'USER INTERACTION CONTROLS', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    
    # Technical annotations (reference markers)
    ax.text(0.8, 8.9, 'A', ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(0.8, 7.9, 'A', ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(0.8, 5.5, 'B', ha='center', va='center', fontsize=14, fontweight='bold')
    ax.text(0.8, 2.9, 'C', ha='center', va='center', fontsize=14, fontweight='bold')
    

    
    plt.tight_layout()
    plt.savefig('figure5_indoor_navigation.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure5_indoor_navigation.png")

def create_map_annotation_system():
    """Generate Figure 6: Map Annotation and Graph Generation System - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 11.6, 7.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 11.2, 7.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(6, 7.2, 'INDOOR NAVIGATION GRAPH GENERATION SYSTEM', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Step 1: High-Resolution Floor Plan Input (adjusted for better spacing)
    step1_box = Rectangle((0.8, 5.0), 2.5, 1.8, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step1_box)
    ax.text(2.05, 6.5, 'HIGH-RESOLUTION', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(2.05, 6.25, 'FLOOR PLAN INPUT', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(2.05, 5.9, 'Building Images', ha='center', va='center', fontsize=9)
    ax.text(2.05, 5.65, 'PNG/JPG Format', ha='center', va='center', fontsize=9)
    ax.text(2.05, 5.4, 'Pixel Coordinates', ha='center', va='center', fontsize=8)
    ax.text(2.05, 5.15, 'Spatial Mapping', ha='center', va='center', fontsize=8)
    
    # Arrow to annotation tool (adjusted for new positioning)
    ax.annotate('', xy=(4, 5.9), xytext=(3.3, 5.9), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Step 2: Python-Based Interactive Annotation Tool (adjusted for better spacing)
    step2_box = Rectangle((4, 5.0), 3, 1.8, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step2_box)
    ax.text(5.5, 6.5, 'PYTHON ANNOTATION', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(5.5, 6.25, 'TOOL (OpenCV)', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(5.5, 5.9, 'Click-Based Placement', ha='center', va='center', fontsize=8)
    ax.text(5.5, 5.65, 'Room and Pathway Marking', ha='center', va='center', fontsize=8)
    ax.text(5.5, 5.4, 'Automatic Link Algorithm', ha='center', va='center', fontsize=8)
    ax.text(5.5, 5.15, 'Interactive Interface', ha='center', va='center', fontsize=8)
    
    # Arrow to graph generation (adjusted for new positioning)
    ax.annotate('', xy=(8, 5.9), xytext=(7, 5.9), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Step 3: NetworkX Graph Processing (adjusted for better spacing)
    step3_box = Rectangle((8, 5.0), 3, 1.8, linewidth=2, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(step3_box)
    ax.text(9.5, 6.5, 'NETWORKX GRAPH', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(9.5, 6.25, 'PROCESSING', ha='center', va='center', 
            fontsize=10, fontweight='bold')
    ax.text(9.5, 5.9, 'Weighted Edge Generation', ha='center', va='center', fontsize=8)
    ax.text(9.5, 5.65, 'Euclidean Distance Calculation', ha='center', va='center', fontsize=8)
    ax.text(9.5, 5.4, 'Connectivity Verification', ha='center', va='center', fontsize=8)
    ax.text(9.5, 5.15, 'Pathfinding Validation', ha='center', va='center', fontsize=8)
    
    # Node Type Classification Section (fixed positioning to avoid overlap)
    node_section = Rectangle((0.8, 3.4), 10.4, 1.2, linewidth=2, 
                            edgecolor='black', facecolor='white')
    ax.add_patch(node_section)
    ax.text(6, 4.3, 'NODE TYPE CLASSIFICATION SYSTEM', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    
    # Room Nodes (fixed spacing to avoid overlap)
    room_box = Rectangle((1.5, 3.5), 4, 0.7, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(room_box)
    ax.text(3.5, 4.0, 'ROOM NODES', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(3.5, 3.7, 'Destinations: Offices, Classrooms, Facilities', ha='center', va='center', fontsize=8)
    
    # Pathway Nodes (fixed spacing to avoid overlap)
    path_box = Rectangle((6.5, 3.5), 4, 0.7, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(path_box)
    ax.text(8.5, 4.0, 'PATHWAY NODES', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(8.5, 3.7, 'Corridors and Connection Points', ha='center', va='center', fontsize=8)
    
    # Process Details Section (fixed positioning to avoid overlap)
    process_box = Rectangle((1, 2.0), 10, 1.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(process_box)
    ax.text(6, 2.9, 'AUTOMATED WORKFLOW PIPELINE', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    
    # Process steps (fixed spacing to avoid overlap)
    ax.text(1.5, 2.6, '1. Load High-Resolution Floor Plan', ha='left', va='center', fontsize=9)
    ax.text(1.5, 2.4, '2. Interactive Node Placement', ha='left', va='center', fontsize=9)
    ax.text(1.5, 2.2, '3. Unique Identifier Assignment', ha='left', va='center', fontsize=9)
    
    ax.text(6, 2.6, '4. Automatic Link Pathway Nodes', ha='left', va='center', fontsize=9)
    ax.text(6, 2.4, '5. Weighted Edge Calculation', ha='left', va='center', fontsize=9)
    ax.text(6, 2.2, '6. JSON Database Export', ha='left', va='center', fontsize=9)
    
    # Output Section (repositioned higher to avoid overlap)
    output_box = Rectangle((1.5, 1.2), 9, 0.6, linewidth=2, 
                          edgecolor='black', facecolor='white')
    ax.add_patch(output_box)
    ax.text(6, 1.65, 'COMPREHENSIVE NAVIGATION DATABASE', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(6, 1.45, 'gdn_ground_floor_graph.json | 185 Nodes | 282 Weighted Edges', ha='center', va='center', 
            fontsize=9)
    ax.text(6, 1.25, 'Dijkstra-Ready Structure | Real-World Spatial Coordinates', ha='center', va='center', 
            fontsize=8)
    
    # Technical Implementation Details (repositioned to avoid overlap and cutoff)
    ax.text(1, 0.9, 'Implementation: Python + OpenCV Computer Vision + NetworkX Graph Algorithms', 
            ha='left', va='center', fontsize=8, fontweight='bold')
    ax.text(1, 0.75, 'Verification: Automated connectivity testing | Shortest path validation | Multi-building scalability', 
            ha='left', va='center', fontsize=8)
    ax.text(1, 0.6, 'Integration: Seamless mobile app compatibility | Real-time pathfinding optimization', 
            ha='left', va='center', fontsize=8)
    

    
    plt.tight_layout()
    plt.savefig('figure6_map_annotation_system.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure6_map_annotation_system.png")

def create_user_interface_design():
    """Generate Figure 9: User Interface Design - Simplified Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 9.6, 9.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 9.2, 9.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 9.2, 'USER INTERFACE DESIGN', 
            ha='center', va='center', fontsize=18, fontweight='bold')
    
    # Top: Main Navigation Interface
    main_ui_box = Rectangle((2, 7.5), 6, 1.2, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(main_ui_box)
    ax.text(5, 8.4, 'MAIN NAVIGATION INTERFACE', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    ax.text(5, 8.0, 'SearchField Destination Selection', ha='center', va='center', fontsize=11)
    ax.text(5, 7.7, 'Dual Mode Controls: 2D Map | AR Camera', ha='center', va='center', fontsize=11)
    
    # Middle Row: Two Main UI Modes
    # Outdoor Navigation UI (Left) - with AR option
    outdoor_ui_box = Rectangle((0.8, 5.2), 3.5, 1.8, linewidth=2, 
                              edgecolor='black', facecolor='white')
    ax.add_patch(outdoor_ui_box)
    ax.text(2.55, 6.6, 'OUTDOOR NAVIGATION UI', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(2.55, 6.2, 'Google Maps + GPS Tracking', ha='center', va='center', fontsize=10)
    ax.text(2.55, 5.9, 'Supports 2D Map View', ha='center', va='center', fontsize=10)
    ax.text(2.55, 5.6, 'Supports AR Camera Mode', ha='center', va='center', fontsize=10)
    ax.text(2.55, 5.3, '(Outdoor Only)', ha='center', va='center', fontsize=9, style='italic')
    
    # Indoor Navigation UI (Right)
    indoor_ui_box = Rectangle((5.7, 5.2), 3.5, 1.8, linewidth=2, 
                             edgecolor='black', facecolor='white')
    ax.add_patch(indoor_ui_box)
    ax.text(7.45, 6.6, 'INDOOR NAVIGATION UI', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(7.45, 6.2, '2D Floor Plan Display', ha='center', va='center', fontsize=10)
    ax.text(7.45, 5.9, 'Path Overlay Visualization', ha='center', va='center', fontsize=10)
    ax.text(7.45, 5.6, 'Dijkstra Pathfinding', ha='center', va='center', fontsize=10)
    ax.text(7.45, 5.3, '(2D View Only)', ha='center', va='center', fontsize=9, style='italic')
    
    # Arrows from main to two modes (FIXED - only 2 arrows)
    ax.annotate('', xy=(2.55, 7.0), xytext=(3.5, 7.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.annotate('', xy=(7.45, 7.0), xytext=(6.5, 7.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Arrows down from two modes to interaction components
    ax.annotate('', xy=(2.55, 4.5), xytext=(2.55, 5.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.annotate('', xy=(7.45, 4.5), xytext=(7.45, 5.2), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # User Interaction Components
    interaction_box = Rectangle((1.5, 3.0), 7, 1.5, linewidth=2, 
                               edgecolor='black', facecolor='white')
    ax.add_patch(interaction_box)
    ax.text(5, 4.2, 'USER INTERACTION COMPONENTS', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    ax.text(5, 3.8, 'Arrival Dialogs | Transition Notifications | Error Handling', 
            ha='center', va='center', fontsize=11)
    ax.text(5, 3.5, 'Material Design | Accessibility | Responsive Layout', 
            ha='center', va='center', fontsize=11)
    ax.text(5, 3.2, 'Interactive Controls | Real-time Feedback', 
            ha='center', va='center', fontsize=11)
    
    # Arrow down to framework
    ax.annotate('', xy=(5, 2.5), xytext=(5, 3.0), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    
    # Design Framework (Bottom)
    framework_box = Rectangle((2, 1.2), 6, 1.3, linewidth=3, 
                             edgecolor='black', facecolor='white')
    ax.add_patch(framework_box)
    ax.text(5, 2.2, 'FLUTTER WIDGET FRAMEWORK', ha='center', va='center', 
            fontsize=14, fontweight='bold')
    ax.text(5, 1.8, 'Cross-Platform Compatibility', ha='center', va='center', fontsize=11)
    ax.text(5, 1.5, 'Modular Components | Consistent Styling', ha='center', va='center', fontsize=11)
    
    plt.tight_layout()
    plt.savefig('figure9_user_interface_design.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure9_user_interface_design.png")

def create_user_flow():
    """Generate Figure 7: User Flow Diagram - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 14))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 9.6, 13.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 9.2, 13.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title
    ax.text(5, 13.2, 'PATHFINDER USER FLOW DIAGRAM', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Step 1: App Launch
    step1 = Rectangle((3, 11.8), 4, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step1)
    ax.text(5, 12.2, '1. USER LAUNCHES APP', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 11.3), xytext=(5, 11.8), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 2: Destination Selection
    step2 = Rectangle((2, 10.5), 6, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step2)
    ax.text(5, 10.9, '2. SELECT DESTINATION (e.g., "G01")', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 10.0), xytext=(5, 10.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 3: Navigation Mode Choice
    step3 = Rectangle((1.5, 9.2), 7, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step3)
    ax.text(5, 9.6, '3. CHOOSE NAVIGATION MODE', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Mode options
    mode_2d = Rectangle((2, 8.5), 2.5, 0.5, linewidth=1, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(mode_2d)
    ax.text(3.25, 8.75, '2D Map View', ha='center', va='center', fontsize=10)
    
    mode_ar = Rectangle((5.5, 8.5), 2.5, 0.5, linewidth=1, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(mode_ar)
    ax.text(6.75, 8.75, 'AR Camera View', ha='center', va='center', fontsize=10)
    
    # Arrows from modes
    ax.annotate('', xy=(3.25, 7.8), xytext=(3.25, 8.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    ax.annotate('', xy=(6.75, 7.8), xytext=(6.75, 8.5), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 4: Outdoor Navigation
    step4 = Rectangle((1.5, 7.0), 7, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step4)
    ax.text(5, 7.4, '4. OUTDOOR GPS NAVIGATION TO BUILDING', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 6.5), xytext=(5, 7.0), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 5: Proximity Detection
    step5 = Rectangle((2.5, 5.7), 5, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step5)
    ax.text(5, 6.1, '5. PROXIMITY DETECTION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(5, 5.85, 'Distance < 25m from Building', ha='center', va='center', 
            fontsize=9, style='italic')
    
    # Arrow down
    ax.annotate('', xy=(5, 5.2), xytext=(5, 5.7), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 6: Automatic Handoff
    step6 = Rectangle((2, 4.4), 6, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step6)
    ax.text(5, 4.8, '6. AUTOMATIC MODE HANDOFF', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Arrow down
    ax.annotate('', xy=(5, 3.9), xytext=(5, 4.4), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 7: Indoor Navigation
    step7 = Rectangle((1.5, 2.6), 7, 1.3, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step7)
    ax.text(5, 3.6, '7. INDOOR NAVIGATION ACTIVATED', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    ax.text(5, 3.2, '• Load building graph (185 nodes)', ha='center', va='center', fontsize=9)
    ax.text(5, 3.0, '• Calculate optimal path to G01', ha='center', va='center', fontsize=9)
    ax.text(5, 2.8, '• Display 2D floor plan with path overlay', ha='center', va='center', fontsize=9)
    
    # Arrow down
    ax.annotate('', xy=(5, 2.1), xytext=(5, 2.6), 
                arrowprops=dict(arrowstyle='->', lw=2, color='black'))
    
    # Step 8: Arrival
    step8 = Rectangle((3, 1.3), 4, 0.8, linewidth=2, 
                     edgecolor='black', facecolor='white')
    ax.add_patch(step8)
    ax.text(5, 1.7, '8. USER REACHES DESTINATION', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Side annotations
    ax.text(0.8, 10.9, 'USER\nINPUT', ha='center', va='center', 
            fontsize=10, fontweight='bold', rotation=90)
    ax.text(0.8, 7.4, 'OUTDOOR\nPHASE', ha='center', va='center', 
            fontsize=10, fontweight='bold', rotation=90)
    ax.text(0.8, 4.8, 'HANDOFF', ha='center', va='center', 
            fontsize=10, fontweight='bold', rotation=90)
    ax.text(0.8, 2.5, 'INDOOR\nPHASE', ha='center', va='center', 
            fontsize=10, fontweight='bold', rotation=90)
    
    # Add figure number (positioned below the border)
    ax.text(5, 0.1, 'Figure 7: Pathfinder User Flow Diagram', 
            ha='center', va='center', fontsize=12, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('figure7_user_flow.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure7_user_flow.png")

def create_outdoor_navigation_module():
    """Generate Figure 8: Outdoor Navigation Module (ONM) - Patent Style"""
    fig, ax = plt.subplots(1, 1, figsize=(12, 10))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Outer border (patent style)
    outer_border = Rectangle((0.2, 0.2), 11.6, 9.6, linewidth=3, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(outer_border)
    
    # Inner border
    inner_border = Rectangle((0.4, 0.4), 11.2, 9.2, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(inner_border)
    
    # Title (moved down to avoid border overlap)
    ax.text(6, 8.9, 'OUTDOOR NAVIGATION MODULE (ONM)', 
            ha='center', va='center', fontsize=16, fontweight='bold')
    
    # Input Sources Section (adjusted positioning)
    input_section = Rectangle((0.8, 7.0), 10.4, 1.5, linewidth=2, 
                             edgecolor='black', facecolor='white')
    ax.add_patch(input_section)
    ax.text(6, 8.2, 'INPUT SOURCES', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # GPS Source (adjusted positioning)
    gps_box = Rectangle((1.2, 7.3), 2, 0.8, linewidth=1, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(gps_box)
    ax.text(2.2, 7.8, 'GPS Satellites', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(2.2, 7.55, 'LocationAccuracy', ha='center', va='center', fontsize=8)
    ax.text(2.2, 7.4, 'bestForNavigation', ha='center', va='center', fontsize=8)
    
    # Google Maps API (adjusted positioning)
    maps_box = Rectangle((3.8, 7.3), 2, 0.8, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(maps_box)
    ax.text(4.8, 7.8, 'Google Maps', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(4.8, 7.6, 'Flutter SDK', ha='center', va='center', fontsize=8)
    ax.text(4.8, 7.45, 'Routing API', ha='center', va='center', fontsize=8)
    
    # Camera & Compass (adjusted positioning)
    camera_box = Rectangle((6.4, 7.3), 2, 0.8, linewidth=1, 
                          edgecolor='black', facecolor='white')
    ax.add_patch(camera_box)
    ax.text(7.4, 7.8, 'Camera & Compass', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(7.4, 7.6, 'AR Components', ha='center', va='center', fontsize=8)
    ax.text(7.4, 7.45, 'Bearing Calculation', ha='center', va='center', fontsize=8)
    
    # User Input (adjusted positioning)
    user_box = Rectangle((8.8, 7.3), 2, 0.8, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(user_box)
    ax.text(9.8, 7.8, 'User Input', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(9.8, 7.6, 'SearchField', ha='center', va='center', fontsize=8)
    ax.text(9.8, 7.45, 'Destination', ha='center', va='center', fontsize=8)
    
    # Core Processing Section (adjusted positioning and spacing)
    core_section = Rectangle((1.5, 5.0), 9, 1.5, linewidth=2, 
                            edgecolor='black', facecolor='white')
    ax.add_patch(core_section)
    ax.text(6, 6.2, 'ONM CORE PROCESSING ENGINE', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # Geolocator Service (better spacing)
    geo_box = Rectangle((2, 5.3), 2.5, 0.8, linewidth=1, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(geo_box)
    ax.text(3.25, 5.8, 'Geolocator Service', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(3.25, 5.6, 'Real-time Tracking', ha='center', va='center', fontsize=8)
    ax.text(3.25, 5.45, 'Position Updates', ha='center', va='center', fontsize=8)
    
    # Route Calculator (better spacing)
    route_box = Rectangle((4.75, 5.3), 2.5, 0.8, linewidth=1, 
                         edgecolor='black', facecolor='white')
    ax.add_patch(route_box)
    ax.text(6, 5.8, 'Route Calculator', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(6, 5.6, 'Optimal Pathfinding', ha='center', va='center', fontsize=8)
    ax.text(6, 5.45, 'Turn-by-turn', ha='center', va='center', fontsize=8)
    
    # Proximity Monitor (better spacing)
    prox_box = Rectangle((7.5, 5.3), 2.5, 0.8, linewidth=1, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(prox_box)
    ax.text(8.75, 5.8, 'Proximity Monitor', ha='center', va='center', fontsize=10, fontweight='bold')
    ax.text(8.75, 5.6, '25m Threshold', ha='center', va='center', fontsize=8)
    ax.text(8.75, 5.45, 'Handoff Trigger', ha='center', va='center', fontsize=8)
    
    # Dual Visualization Modes (fixed positioning to avoid overlap)
    viz_section = Rectangle((1, 2.6), 10, 2.0, linewidth=2, 
                           edgecolor='black', facecolor='white')
    ax.add_patch(viz_section)
    ax.text(6, 4.3, 'DUAL VISUALIZATION MODES', ha='center', va='center', 
            fontsize=12, fontweight='bold')
    
    # 2D Map Mode (fixed positioning with proper spacing)
    map_mode = Rectangle((1.5, 2.8), 4, 1.2, linewidth=2, 
                        edgecolor='black', facecolor='white')
    ax.add_patch(map_mode)
    ax.text(3.5, 3.7, '2D MAP VIEW MODE', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(3.5, 3.45, '• Interactive Google Maps Interface', ha='center', va='center', fontsize=9)
    ax.text(3.5, 3.25, '• Route Polyline Overlays', ha='center', va='center', fontsize=9)
    ax.text(3.5, 3.05, '• Directional Markers & Navigation', ha='center', va='center', fontsize=9)
    
    # AR Mode (fixed positioning with proper spacing)
    ar_mode = Rectangle((6.5, 2.8), 4, 1.2, linewidth=2, 
                       edgecolor='black', facecolor='white')
    ax.add_patch(ar_mode)
    ax.text(8.5, 3.7, 'AR CAMERA VIEW MODE', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(8.5, 3.45, '• Live Camera Feed Overlay', ha='center', va='center', fontsize=9)
    ax.text(8.5, 3.25, '• Real-time Navigation Arrows', ha='center', va='center', fontsize=9)
    ax.text(8.5, 3.05, '• Compass-based Directional Guidance', ha='center', va='center', fontsize=9)
    
    # Output Section (adjusted positioning)
    output_section = Rectangle((2.5, 1.0), 7, 1.2, linewidth=2, 
                              edgecolor='black', facecolor='white')
    ax.add_patch(output_section)
    ax.text(6, 1.9, 'OUTPUT TO AUTONOMOUS TRANSITION CONTROL', ha='center', va='center', 
            fontsize=11, fontweight='bold')
    ax.text(6, 1.6, 'Real-time GPS Coordinates | Distance Measurements | Proximity Status', 
            ha='center', va='center', fontsize=9)
    ax.text(6, 1.3, 'Battery-optimized Location Updates | Handoff Trigger Signals', 
            ha='center', va='center', fontsize=9)
    
    # Data Flow Arrows (simplified with single arrows)
    # Single arrow from Input Sources to Core Processing
    ax.annotate('', xy=(6, 6.5), xytext=(6, 7.0), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(6.3, 6.75, 'Input Data Flow', ha='left', va='center', fontsize=8, style='italic')
    
    # Single arrow from Core Processing to Visualization Modes
    ax.annotate('', xy=(6, 4.6), xytext=(6, 5.0), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(6.3, 4.8, 'Processing Output', ha='left', va='center', fontsize=8, style='italic')
    
    # Single arrow from Visualization to Output
    ax.annotate('', xy=(6, 2.2), xytext=(6, 2.6), 
                arrowprops=dict(arrowstyle='->', lw=3, color='black'))
    ax.text(6.3, 2.4, 'System Output', ha='left', va='center', fontsize=8, style='italic')
    
    plt.tight_layout()
    plt.savefig('figure8_outdoor_navigation_module.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='black')
    plt.close()
    print("✅ Generated: figure8_outdoor_navigation_module.png")

def main():
    """Generate all patent diagrams"""
    print("🎨 Generating Patent-Style Diagrams for Pathfinder Indoor Navigation...")
    print("=" * 60)
    
    create_system_architecture()
    create_pathfinder_flow()
    create_graph_generation()
    create_mode_transition()
    create_indoor_navigation()
    create_map_annotation_system()
    create_user_flow()
    create_outdoor_navigation_module()
    create_user_interface_design()
    
    print("=" * 60)
    print("🎉 All diagrams generated successfully!")
    print("\nGenerated files:")
    print("• figure1_system_architecture.png")
    print("• figure2_pathfinder_flow.png")
    print("• figure3_data_processing.png")
    print("• figure4_system_integration.png")
    print("• figure5_indoor_navigation.png")
    print("• figure6_map_annotation_system.png")
    print("• figure7_user_flow.png")
    print("• figure8_outdoor_navigation_module.png")
    print("• figure9_user_interface_design.png")
    print("\n📋 These high-resolution PNG files are ready for your patent application!")
    print("\n🎯 Style: Classic patent diagrams with black and white line drawings")
    print("📐 Format: Clean rectangular boxes, simple arrows, professional borders")

if __name__ == "__main__":
    main()