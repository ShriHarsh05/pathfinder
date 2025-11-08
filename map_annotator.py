import cv2
import numpy as np
import networkx as nx
import math
import json
import os
import sys

# --- CONFIGURATION ---
MAP_IMAGE_PATH = os.path.join('assets', 'maps', 'gdn_ground_floor_clean.png')
OUTPUT_JSON_FILE = os.path.join('assets', 'maps', 'gdn_ground_floor_graph.json')
TEMP_IMAGE_PATH = 'temp_annotated_map.png' # This is your reference map
MAX_DISPLAY_HEIGHT = 800
MAX_AUTO_LINK_DISTANCE = 40.0 

# --- SCRIPT ---

nodes_data = {"nodes": []}
edges_data = {"edges": []}
temp_img = None
window_name = "Map Annotation - Click nodes, then press ESC"

def click_event(event, x, y, flags, param):
    global nodes_data, temp_img
    
    scale_factor = param[0]
    disp_w = param[1]
    disp_h = param[2]

    if event == cv2.EVENT_LBUTTONDOWN:
        orig_x = int(x / scale_factor)
        orig_y = int(y / scale_factor)
        node_id = len(nodes_data["nodes"])
        
        print(f"\nClicked at window(x,y): ({x},{y}) -> map(x,y): ({orig_x},{orig_y}).")
        node_type = input(f"  Enter type for node {node_id} ('room' or 'path'): ").strip().lower()
        while node_type not in ['room', 'path']:
            node_type = input("  Invalid type. Enter 'room' or 'path': ").strip().lower()

        node_name = None
        if node_type == 'room':
            node_name = input(f"  Enter room name for node {node_id} (e.g., G01): ").strip()
            color = (0, 0, 255) # Red for rooms
        else:
            color = (255, 0, 0) # Blue for path

        new_node = {
            "id": node_id, "x": orig_x, "y": orig_y,
            "type": node_type, "name": node_name
        }
        nodes_data["nodes"].append(new_node)

        # Draw on the FULL resolution temp_img using ORIGINAL coordinates
        cv2.circle(temp_img, (orig_x, orig_y), 5, color, -1)
        cv2.putText(temp_img, f"{node_id}", (orig_x + 5, orig_y - 5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        
        # Save the FULL resolution temp image
        cv2.imwrite(TEMP_IMAGE_PATH, temp_img)
        
        # Resize the newly drawn full-res image for display
        display_img = cv2.resize(temp_img, (disp_w, disp_h))
        cv2.imshow(window_name, display_img)

def main():
    global temp_img, nodes_data, edges_data

    # Load your map image
    if not os.path.exists(MAP_IMAGE_PATH):
        print(f"Error: Could not find map image at {MAP_IMAGE_PATH}")
        return
    img = cv2.imread(MAP_IMAGE_PATH)
    if img is None:
        print(f"Error: Could not load image at {MAP_IMAGE_PATH}.")
        return
    temp_img = img.copy()
    
    # Calculate scaled dimensions
    h, w = img.shape[:2]
    if h > MAX_DISPLAY_HEIGHT:
        scale_factor = MAX_DISPLAY_HEIGHT / h
        disp_w = int(w * scale_factor)
        disp_h = int(h * scale_factor)
    else:
        scale_factor = 1.0
        disp_w = w
        disp_h = h
    print(f"Original map size: {w}x{h}. Displaying at: {disp_w}x{disp_h} (Scale: {scale_factor:.2f})")

    # Create resizable window
    cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
    cv2.resizeWindow(window_name, disp_w, disp_h)
    
    # Load existing JSON data
    if os.path.exists(OUTPUT_JSON_FILE):
        print(f"Loading existing graph data from {OUTPUT_JSON_FILE}...")
        try:
            with open(OUTPUT_JSON_FILE, 'r') as f:
                data = json.load(f)
                if "nodes" in data:
                    nodes_data["nodes"] = data["nodes"]
                    print(f"Loaded {len(nodes_data['nodes'])} existing nodes.")
                if "edges" in data:
                    edges_data["edges"] = data["edges"]
                    print(f"Loaded {len(edges_data['edges'])} existing edges.")
        except Exception as e:
            print(f"Could not parse existing JSON: {e}. Starting fresh.")
            nodes_data = {"nodes": []}
            edges_data = {"edges": []}
    
    # --- FIX: Re-draw nodes onto temp_img from loaded data ---
    # This ensures temp_img has all 185 nodes drawn on it,
    # even if the temp file was deleted.
    for node in nodes_data["nodes"]:
        color = (0, 0, 255) if node['type'] == 'room' else (255, 0, 0)
        cv2.circle(temp_img, (node['x'], node['y']), 5, color, -1)
        cv2.putText(temp_img, f"{node['id']}", (node['x'] + 5, node['y'] - 5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
    # Save this as the new temp file
    cv2.imwrite(TEMP_IMAGE_PATH, temp_img)
    
    
    display_img = cv2.resize(temp_img, (disp_w, disp_h))
    print("\n--- Step 1: Mark Nodes (Optional) ---")
    print("Your nodes are loaded. Press 'ESC' to move to edge linking.")
    cv2.imshow(window_name, display_img)
    callback_param = [scale_factor, disp_w, disp_h]
    cv2.setMouseCallback(window_name, click_event, callback_param)
    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == 27: break
    cv2.destroyAllWindows()

    if not nodes_data["nodes"]:
        print("No nodes marked. Exiting.")
        return

    nodes = nodes_data["nodes"]
    
    # --- STEP 2: AUTOMATIC HALLWAY LINKING ---
    print(f"\n--- Step 2: Auto-linking 'path' nodes ---")
    print(f"Finding closest 'path' neighbors within {MAX_AUTO_LINK_DISTANCE} pixels...")
    
    added_edges = set() 
    for edge in edges_data["edges"]:
        added_edges.add(tuple(sorted((edge["source"], edge["target"]))))

    new_auto_edges = 0
    verification_img = img.copy() # Use a fresh copy to draw on
    
    for node_a in nodes:
        if node_a['type'] != 'path':
            continue # Only link path-to-path

        closest_neighbor = None
        min_dist = float('inf')

        for node_b in nodes:
            if node_a['id'] == node_b['id'] or node_b['type'] != 'path':
                continue
            
            if tuple(sorted((node_a['id'], node_b['id']))) in added_edges:
                continue

            dist = math.dist((node_a['x'], node_a['y']), (node_b['x'], node_b['y']))
            
            if dist < min_dist:
                min_dist = dist
                closest_neighbor = node_b
        
        if closest_neighbor and min_dist <= MAX_AUTO_LINK_DISTANCE:
            a_id = node_a['id']
            b_id = closest_neighbor['id']
            
            new_edge = {"source": a_id, "target": b_id, "weight": min_dist}
            edges_data["edges"].append(new_edge)
            added_edges.add(tuple(sorted((a_id, b_id))))
            
            cv2.line(verification_img, (node_a['x'], node_a['y']), (closest_neighbor['x'], closest_neighbor['y']), (0, 255, 0), 2)
            new_auto_edges += 1

    print(f"Automatically added {new_auto_edges} new hallway edges.")

    # --- Step 3: Manual Linking ---
    print(f"\n--- Step 3: Manual Linking (for Rooms & Missed Paths) ---")
    print("All 'path' nodes have been auto-linked.")
    print("Your job is to manually connect 'room' nodes (like G01) to the path.")
    
    # --- FIX: RE-DRAW NODES AND EDGES on verification_img ---
    # Draw existing edges
    for edge in edges_data["edges"]:
        if edge["source"] < len(nodes) and edge["target"] < len(nodes):
            a_pos = (nodes[edge["source"]]['x'], nodes[edge["source"]]['y'])
            b_pos = (nodes[edge["target"]]['x'], nodes[edge["target"]]['y'])
            cv2.line(verification_img, a_pos, b_pos, (0, 255, 0), 2) # Green for edges
    # Draw nodes on top
    for node in nodes:
        color = (0, 0, 255) if node['type'] == 'room' else (255, 0, 0)
        cv2.circle(verification_img, (node['x'], node['y']), 5, color, -1)
        cv2.putText(verification_img, f"{node['id']}", (node['x'] + 5, node['y'] - 5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

    # --- FIX: Save this as the new reference map ---
    cv2.imwrite(TEMP_IMAGE_PATH, verification_img)
    print(f"Reference map with all nodes and auto-edges saved to {TEMP_IMAGE_PATH}")
    
    print("\nNodes marked (ID: x, y, type, name):")
    for node in nodes:
        print(f"  {node['id']}: ({node['x']}, {node['y']}, {node['type']}, {node.get('name', 'N/A')})")
    print("\nEnter edges as pairs of node IDs (e.g., 0 1). Type 'done' when finished.")


    while True:
        user_input = input("Edge: ").strip().lower()
        if user_input == "done":
            break
        try:
            a_id, b_id = map(int, user_input.split())
            if a_id >= len(nodes) or b_id >= len(nodes) or a_id < 0 or b_id < 0:
                print("Invalid ID. Node IDs must be between 0 and", len(nodes) - 1)
                continue
            
            if tuple(sorted((a_id, b_id))) in added_edges:
                print(f"  Edge {a_id}-{b_id} already exists. Skipping.")
                continue

            node_a = nodes[a_id]
            node_b = nodes[b_id]
            x1, y1 = node_a['x'], node_a['y']
            x2, y2 = node_b['x'], node_b['y']
            distance = math.dist((x1, y1), (x2, y2))
            
            new_edge = {"source": a_id, "target": b_id, "weight": distance}
            edges_data["edges"].append(new_edge)
            added_edges.add(tuple(sorted((a_id, b_id))))
            
            cv2.line(verification_img, (x1, y1), (x2, y2), (0, 255, 0), 2)
            print(f"  Added edge {a_id} <-> {b_id} with weight {distance:.2f}")

        except Exception as e:
            print(f"Invalid input. Try again. Error: {e}")

    # Combine data and save
    final_graph = {"nodes": nodes_data["nodes"], "edges": edges_data["edges"]}
    try:
        with open(OUTPUT_JSON_FILE, 'w') as f:
            json.dump(final_graph, f, indent=4)
        print(f"\nSuccessfully exported graph data to {OUTPUT_JSON_FILE}")
    except Exception as e:
        print(f"Error saving JSON file: {e}")

    # --- Step 4: Verification ---
    print("\n--- Step 4: Verify Path (Optional) ---")
    while True:
        try:
            start_s = input("Enter start node ID to test path (or 'skip'): ").strip().lower()
            if start_s == 'skip':
                break
            end_s = input("Enter end node ID to test path: ").strip().lower()
            
            start_id = int(start_s)
            end_id = int(end_s)

            G = nx.Graph()
            for edge in edges_data["edges"]:
                G.add_edge(edge["source"], edge["target"], weight=edge["weight"])

            path = nx.shortest_path(G, source=start_id, target=end_id, weight="weight")
            print("\nShortest path (node IDs):", path)

            path_img = verification_img.copy() # Make a copy to draw the red path
            for i in range(len(path) - 1):
                a_id, b_id = path[i], path[i + 1]
                a_pos = (nodes[a_id]['x'], nodes[a_id]['y'])
                b_pos = (nodes[b_id]['x'], nodes[b_id]['y'])
                cv2.line(path_img, a_pos, b_pos, (0, 0, 255), 3) # Draw thick red line

            display_verify_img = cv2.resize(path_img, (disp_w, disp_h))
            cv2.imshow("Shortest Path Verification", display_verify_img)
            print("Press any key to test another path, or 'ESC' to exit.")
            
            key = cv2.waitKey(0)
            if key == 27: break
                
        except nx.NetworkXNoPath:
            print("Error: No path found between those nodes.")
        except Exception as e:
            print(f"Invalid input: {e}. Try again.")

    cv2.destroyAllWindows()
    # We'll keep the temp file now for reference
    print(f"\nAnnotation complete. Your reference map is at {TEMP_IMAGE_PATH}")

if __name__ == "__main__":
    print("--- Map Annotation Script ---")
    
    # --- THIS IS THE FIX ---
    # Change directory to the script's location (your project root)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir) 
    # --- END FIX ---
    
    print(f"Project Root: {os.path.abspath(os.getcwd())}")
    print(f"Reading map from: {os.path.abspath(MAP_IMAGE_PATH)}")
    print(f"Will save/load graph to: {os.path.abspath(OUTPUT_JSON_FILE)}")
    print("Please ensure you have run: pip install opencv-python networkx")
    main()