import cv2
import numpy as np
import networkx as nx
import math
import json
import os

# --- CONFIGURATION ---
# This script is designed to be run from the root of your Flutter project.

# 1. Path to the CLEAN map image (inside your assets)
MAP_IMAGE_PATH = os.path.join('assets', 'maps', 'map.png')

# 2. Path where the FINAL JSON graph will be saved
OUTPUT_JSON_FILE = os.path.join('assets', 'maps', 'gdn_ground_floor_graph.json')

# 3. Path for the temporary image (will be deleted)
TEMP_IMAGE_PATH = 'temp_annotated_map.png'

# --- SCRIPT ---

# Global variables
nodes_data = {"nodes": []}
edges_data = {"edges": []}
temp_img = None
window_name = "Map Annotation - Click nodes, then press ESC"

def click_event(event, x, y, flags, param):
    global nodes_data, temp_img
    if event == cv2.EVENT_LBUTTONDOWN:
        node_id = len(nodes_data["nodes"])
        
        # Ask for node type
        print(f"\nClicked at ({x},{y}).")
        node_type = input(f"  Enter type for node {node_id} ('room' or 'path'): ").strip().lower()
        while node_type not in ['room', 'path']:
            node_type = input("  Invalid type. Enter 'room' or 'path': ").strip().lower()

        node_name = None
        if node_type == 'room':
            node_name = input(f"  Enter room name for node {node_id} (e.g., G01): ").strip()
            color = (0, 0, 255) # Red for rooms
        else:
            color = (255, 0, 0) # Blue for path

        # Store node
        new_node = {
            "id": node_id,
            "x": x,
            "y": y,
            "type": node_type,
            "name": node_name
        }
        nodes_data["nodes"].append(new_node)

        # Draw on temp image
        cv2.circle(temp_img, (x, y), 5, color, -1)
        cv2.putText(temp_img, f"{node_id}", (x + 5, y - 5),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
        cv2.imshow(window_name, temp_img)
        
        # Save temp image so user can see annotations if script crashes
        cv2.imwrite(TEMP_IMAGE_PATH, temp_img)


def main():
    global temp_img

    # Load your map image
    if not os.path.exists(MAP_IMAGE_PATH):
        print(f"Error: Could not find map image at {MAP_IMAGE_PATH}")
        print("Please make sure the file exists and the path is correct.")
        return

    img = cv2.imread(MAP_IMAGE_PATH)
    if img is None:
        print(f"Error: Could not load image at {MAP_IMAGE_PATH}. File may be corrupt.")
        return
        
    temp_img = img.copy()
    
    # Check if a temp file exists
    if os.path.exists(TEMP_IMAGE_PATH):
        print("Found existing annotations. Loading them.")
        temp_img = cv2.imread(TEMP_IMAGE_PATH)
        if os.path.exists(OUTPUT_JSON_FILE):
            try:
                with open(OUTPUT_JSON_FILE, 'r') as f:
                    data = json.load(f)
                    if "nodes" in data:
                        nodes_data["nodes"] = data["nodes"]
                        print(f"Loaded {len(nodes_data['nodes'])} existing nodes.")
            except Exception as e:
                print(f"Could not parse existing JSON: {e}. Starting fresh.")
                nodes_data["nodes"] = []

    print("\n--- Step 1: Mark Nodes ---")
    print("Click on the image to mark nodes (room entrances, hallway turns).")
    print("Press the 'ESC' key when you are finished marking nodes.")
    cv2.imshow(window_name, temp_img)
    cv2.setMouseCallback(window_name, click_event)

    # Wait for ESC key
    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == 27:  # ESC key
            break
    cv2.destroyAllWindows()

    if not nodes_data["nodes"]:
        print("No nodes marked. Exiting.")
        return

    # --- Step 2: Define Edges ---
    print(f"\n--- Step 2: Define Edges ---")
    print("Nodes marked (ID: x, y, type, name):")
    for node in nodes_data["nodes"]:
        print(f"  {node['id']}: ({node['x']}, {node['y']}, {node['type']}, {node.get('name', 'N/A')})")
    
    print("\nEnter edges as pairs of node IDs (e.g., 0 1).")
    print("Type 'done' when finished.")
    
    nodes = nodes_data["nodes"] # Quick access
    
    while True:
        user_input = input("Edge: ").strip().lower()
        if user_input == "done":
            break
        try:
            a_id, b_id = map(int, user_input.split())
            if a_id >= len(nodes) or b_id >= len(nodes) or a_id < 0 or b_id < 0:
                print("Invalid ID. Node IDs must be between 0 and", len(nodes) - 1)
                continue
                
            # Get coordinates
            node_a = nodes[a_id]
            node_b = nodes[b_id]
            
            # Calculate Euclidean distance as weight
            x1, y1 = node_a['x'], node_a['y']
            x2, y2 = node_b['x'], node_b['y']
            distance = math.dist((x1, y1), (x2, y2))
            
            new_edge = {"source": a_id, "target": b_id, "weight": distance}
            edges_data["edges"].append(new_edge)
            
            # Draw edge on the image
            cv2.line(img, (x1, y1), (x2, y2), (0, 255, 0), 2)
            print(f"  Added edge {a_id} <-> {b_id} with weight {distance:.2f}")

        except Exception as e:
            print(f"Invalid input. Try again. Error: {e}")

    # Combine data and save to JSON
    final_graph = {
        "nodes": nodes_data["nodes"],
        "edges": edges_data["edges"]
    }
    
    try:
        with open(OUTPUT_JSON_FILE, 'w') as f:
            json.dump(final_graph, f, indent=4)
        print(f"\nSuccessfully exported graph data to {OUTPUT_JSON_FILE}")
    except Exception as e:
        print(f"Error saving JSON file: {e}")

    # --- Step 3: Verification ---
    print("\n--- Step 3: Verify Path (Optional) ---")
    while True:
        try:
            start_s = input("Enter start node ID to test path (or 'skip'): ").strip().lower()
            if start_s == 'skip':
                break
            end_s = input("Enter end node ID to test path: ").strip().lower()
            
            start_id = int(start_s)
            end_id = int(end_s)

            # Build graph
            G = nx.Graph()
            for edge in edges_data["edges"]:
                G.add_edge(edge["source"], edge["target"], weight=edge["weight"])

            # Compute shortest path
            path = nx.shortest_path(G, source=start_id, target=end_id, weight="weight")
            print("\nShortest path (node IDs):", path)

            # Draw path on image
            for i in range(len(path) - 1):
                a_id, b_id = path[i], path[i + 1]
                a_pos = (nodes[a_id]['x'], nodes[a_id]['y'])
                b_pos = (nodes[b_id]['x'], nodes[b_id]['y'])
                cv2.line(img, a_pos, b_pos, (0, 0, 255), 3) # Draw thick red line

            cv2.imshow("Shortest Path Verification", img)
            print("Press any key to test another path, or 'ESC' to exit.")
            key = cv2.waitKey(0)
            if key == 27: # ESC key
                break
            else:
                img = cv2.imread(MAP_IMAGE_PATH) # Reset image for next test
                
        except nx.NetworkXNoPath:
            print("Error: No path found between those nodes.")
        except Exception as e:
            print(f"Invalid input: {e}. Try again.")

    cv2.destroyAllWindows()
    if os.path.exists(TEMP_IMAGE_PATH):
        os.remove(TEMP_IMAGE_PATH)
    print("\nAnnotation complete.")

if __name__ == "__main__":
    print("--- Map Annotation Script ---")
    print(f"Reading map from: {os.path.abspath(MAP_IMAGE_PATH)}")
    print(f"Will save graph to: {os.path.abspath(OUTPUT_JSON_FILE)}")
    print("Please ensure you have run: pip install opencv-python networkx")
    main()
# import cv2
# import numpy as np
# import networkx as nx
# import math
# import json # Import the json module

# # Global variables
# nodes_data = []  # Will store dictionaries: {'id': i, 'x': x, 'y': y, 'type': type, 'name': name_optional}
# edges_data = []  # Will store tuples: (node_id_a, node_id_b)
# temp_img = None

# def click_event(event, x, y, flags, param):
#     global nodes_data, temp_img
#     if event == cv2.EVENT_LBUTTONDOWN:
#         node_type = input(f"Enter type for node at ({x},{y}) - 'room' or 'path': ").strip().lower()
#         while node_type not in ['room', 'path']:
#             node_type = input("Invalid type. Enter 'room' or 'path': ").strip().lower()

#         node_name = None
#         if node_type == 'room':
#             node_name = input(f"Enter name for room node at ({x},{y}): ").strip()
#             while not node_name: # Ensure name is not empty for rooms
#                 node_name = input("Room name cannot be empty. Enter name: ").strip()

#         # Store node as a dictionary with an ID
#         node_id = len(nodes_data)
#         nodes_data.append({
#             'id': node_id,
#             'x': x,
#             'y': y,
#             'type': node_type,
#             'name': node_name # Will be None for 'path' nodes
#         })

#         # Draw node
#         color = (0, 0, 255) if node_type == 'room' else (255, 0, 0)
#         cv2.circle(temp_img, (x, y), 5, color, -1)
#         cv2.putText(temp_img, f"{node_id}", (x + 5, y - 5),
#                     cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1) # Display node ID
#         cv2.imshow("Map", temp_img)


# # --- Configuration ---
# MAP_IMAGE_PATH = "map.png" # <--- IMPORTANT: Change this to your map image file name
# OUTPUT_JSON_FILE = "gdn_ground_floor_graph.json"
# # ---------------------

# # Load your map image
# img = cv2.imread(MAP_IMAGE_PATH)
# if img is None:
#     print(f"Error: Could not load image at {MAP_IMAGE_PATH}. Please check the path and file name.")
#     exit()
# temp_img = img.copy()

# print("--- NODE MARKING ---")
# print("Click on the image to mark nodes. For 'room' nodes, you'll be prompted for a name.")
# print("Press ESC when done marking all nodes.")
# cv2.imshow("Map", temp_img)
# cv2.setMouseCallback("Map", click_event)

# while True:
#     key = cv2.waitKey(1) & 0xFF
#     if key == 27:  # ESC key
#         break

# cv2.destroyAllWindows()

# # Print all nodes for verification
# print("\nNodes marked (id, x, y, type, name):")
# for node in nodes_data:
#     print(f"ID {node['id']}: ({node['x']}, {node['y']}), Type: {node['type']}, Name: {node['name']}")

# # Connect nodes manually
# print("\n--- EDGE CONNECTION ---")
# print("Enter edges as pairs of node indices (e.g., 0 1). Enter 'done' when finished.")
# print("Look at the console output above for node IDs.")
# while True:
#     user_input = input("Edge (Node_ID_A Node_ID_B): ")
#     if user_input.lower() == "done":
#         break
#     try:
#         a, b = map(int, user_input.split())
#         # Basic validation for node IDs
#         if 0 <= a < len(nodes_data) and 0 <= b < len(nodes_data):
#             edges_data.append((a, b))
#         else:
#             print(f"Invalid node ID. Please enter IDs between 0 and {len(nodes_data) - 1}.")
#     except ValueError:
#         print("Invalid input format. Please enter two integers separated by a space (e.g., '0 1').")
#     except Exception as e:
#         print(f"An unexpected error occurred: {e}. Try again.")

# print("\nEdges defined:", edges_data)

# # --- Build graph for internal shortest path (optional, but good for verification) ---
# G = nx.Graph()
# for node_dict in nodes_data:
#     G.add_node(node_dict['id'], pos=(node_dict['x'], node_dict['y']), type=node_dict['type'], name=node_dict['name'])

# for (a, b) in edges_data:
#     x1, y1 = nodes_data[a]['x'], nodes_data[a]['y']
#     x2, y2 = nodes_data[b]['x'], nodes_data[b]['y']
#     distance = math.dist((x1, y1), (x2, y2))
#     G.add_edge(a, b, weight=distance)

# print("\nGraph created for verification.")

# # --- JSON Export ---
# print(f"\n--- EXPORTING TO {OUTPUT_JSON_FILE} ---")

# # Prepare data for JSON
# export_nodes = []
# for node in nodes_data:
#     export_nodes.append({
#         'id': node['id'],
#         'x': node['x'],
#         'y': node['y'],
#         'type': node['type'],
#         'name': node['name'] if node['name'] else None # Store None if no name for path nodes
#     })

# export_edges = []
# for (a, b) in edges_data:
#     x1, y1 = nodes_data[a]['x'], nodes_data[a]['y']
#     x2, y2 = nodes_data[b]['x'], nodes_data[b]['y']
#     weight = math.dist((x1, y1), (x2, y2))
#     export_edges.append({
#         'source': a,
#         'target': b,
#         'weight': weight
#     })

# graph_data = {
#     "nodes": export_nodes,
#     "edges": export_edges
# }

# try:
#     with open(OUTPUT_JSON_FILE, 'w') as f:
#         json.dump(graph_data, f, indent=4)
#     print(f"Successfully exported graph data to {OUTPUT_JSON_FILE}")
# except Exception as e:
#     print(f"Error exporting JSON: {e}")

# # --- Optional: Shortest path and drawing for verification ---
# if len(nodes_data) > 1 and G.number_of_edges() > 0:
#     try:
#         start_node_index_input = input("\nEnter start node ID for path verification (or 'skip'): ")
#         if start_node_index_input.lower() != 'skip':
#             start = int(start_node_index_input)
#             end_node_index_input = input("Enter end node ID for path verification: ")
#             end = int(end_node_index_input)

#             if G.has_node(start) and G.has_node(end):
#                 path = nx.shortest_path(G, source=start, target=end, weight="weight")
#                 print("\nShortest path:", path)

#                 # Draw path on a copy of the original image
#                 path_img = cv2.imread(MAP_IMAGE_PATH)
#                 for i in range(len(path) - 1):
#                     a_coords = (nodes_data[path[i]]['x'], nodes_data[path[i]]['y'])
#                     b_coords = (nodes_data[path[i+1]]['x'], nodes_data[path[i+1]]['y'])
#                     cv2.line(path_img, a_coords, b_coords, (0, 255, 0), 2) # Green line
                
#                 # Draw nodes for better visualization
#                 for node_dict in nodes_data:
#                     color = (0, 0, 255) if node_dict['type'] == 'room' else (255, 0, 0) # Red for room, blue for path
#                     cv2.circle(path_img, (node_dict['x'], node_dict['y']), 5, color, -1)
#                     cv2.putText(path_img, f"{node_dict['id']}", (node_dict['x'] + 5, node_dict['y'] - 5),
#                                 cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

#                 cv2.imshow("Shortest Path Verification", path_img)
#                 cv2.waitKey(0)
#                 cv2.destroyAllWindows()
#             else:
#                 print("Start or end node ID not found in graph.")
#         else:
#             print("Skipping path verification.")
#     except Exception as e:
#         print(f"Error during path verification: {e}")
# else:
#     print("Not enough nodes or edges to compute shortest path for verification.")

# print("\n--- SCRIPT FINISHED ---")
