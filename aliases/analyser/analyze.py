filename = "/home/partha_pp.iitr/bin/analyser/data.txt"

with open(filename, "r") as file:
    lines = file.readlines()

headers = lines[0].split()
nodes_used = {}
running_nodes = {}
pending_nodes = {}
total_running_time = 0
total_running_time_per_node=0
running_count = 0
pd_count = 0

for line in lines[1:]:
    values = line.split()
    partition = values[1]
    state = values[4]
    nodes = int(values[6]) if len(values) > 6 else 1

    if partition in nodes_used:
        nodes_used[partition] += nodes
    else:
        nodes_used[partition] = nodes

    if state == "R":
        if partition in running_nodes:
            running_nodes[partition] += nodes
        else:
            running_nodes[partition] = nodes
        running_count += 1

        if len(values) > 5:
            time_parts = values[5].split(':')
            if len(time_parts) >= 3:
                try:
                    days = 0
                    if "-" in time_parts[0]:
                        day_parts = time_parts[0].split('-')
                        days = int(day_parts[0])
                        time_parts[0] = day_parts[1]

                    running_time = days * 24 * 3600 + int(time_parts[0]) * 3600 + int(time_parts[1]) * 60 + int(time_parts[2])
                    total_running_time += running_time
                    total_running_time_per_node+= running_time*nodes
                except ValueError:
                    continue

    elif state == "PD":
        if partition in pending_nodes:
            pending_nodes[partition] += nodes
        else:
            pending_nodes[partition] = nodes
        pd_count += 1

print("Nodes used per partition:")
for partition, count in nodes_used.items():
    print(f"{partition}: {count}")


average_running_time = total_running_time / running_count if running_count > 0 else 0
average_days = average_running_time // (24 * 3600)
average_hours = (average_running_time % (24 * 3600)) // 3600
average_minutes = (average_running_time % 3600) // 60
average_seconds = average_running_time % 60
average_time_str = f"{int(average_days)}-{int(average_hours)}:{int(average_minutes)}:{int(average_seconds)}"
print(f"\nAverage running time : {average_time_str}")


print("\nNumber of running nodes (R) per partition:")
temp =0 
for partition, count in running_nodes.items():
    temp +=count
    print(f"{partition}: {count}")
print(f"Total: {temp}")


average_running_time= total_running_time_per_node / temp if temp > 0 else 0
average_days = average_running_time // (24 * 3600)
average_hours = (average_running_time % (24 * 3600)) // 3600
average_minutes = (average_running_time % 3600) // 60
average_seconds = average_running_time % 60
average_time_str = f"{int(average_days)}-{int(average_hours)}:{int(average_minutes)}:{int(average_seconds)}"
print(f"\nAverage running time per node: {average_time_str}")

temp =0
print("\nNumber of pending nodes (PD) per partition:")
for partition, count in pending_nodes.items():
    temp+=count
    print(f"{partition}: {count}")
print(f"Total: {temp}")

print("\nCount of R and PD states:")
print(f"R: {running_count}")
print(f"PD: {pd_count}")
