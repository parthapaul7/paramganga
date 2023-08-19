import os
def read_xdtcar(filename):
    if os.path.getsize(filename) == 0:
        print("zero file size")
        return []
    with open(filename, "r") as file:
        lines = file.readlines()

    configurations = []
    current_config = []
    start_reading = False

    for line in lines:
        if line.startswith("Direct configuration="):
            if current_config:
                configurations.append(current_config)
            current_config = []
            start_reading = True
        elif start_reading and line.strip() != "":
            coords = list(map(float, line.split()))
            current_config.append(coords)
    
    if current_config:
        configurations.append(current_config)
    
    return configurations

def write_xdtcar(header_info, configurations, output_filename):
    with open(output_filename, "w") as file:
        # Write the header info from the first file
        file.write(header_info)

        for i, config in enumerate(configurations, start=1):
            file.write("Direct configuration={:>6}\n".format(i))
            for coords in config:
                if(coords[0] < 0): 
                    if(coords[1] < 0):
                        if(coords[2] < 0):
                            file.write(f"  {coords[0]:.8f} {coords[1]:.8f} {coords[2]:.8f}\n")
                        else:
                            file.write(f"  {coords[0]:.8f} {coords[1]:.8f}  {coords[2]:.8f}\n")
                    else:
                        file.write(f"  {coords[0]:.8f}  {coords[1]:.8f}  {coords[2]:.8f}\n")
                elif(coords[1] < 0):
                    if(coords[2] < 0): 
                        file.write(f"   {coords[0]:.8f} {coords[1]:.8f} {coords[2]:.8f}\n")
                    else:
                        file.write(f"   {coords[0]:.8f} {coords[1]:.8f}  {coords[2]:.8f}\n")
                elif(coords[2] < 0):
                    file.write(f"   {coords[0]:.8f}  {coords[1]:.8f} {coords[2]:.8f}\n")
                else:
                    file.write(f"   {coords[0]:.8f}  {coords[1]:.8f}  {coords[2]:.8f}\n")
 


if __name__ == "__main__":
    file2 = None
    for i in range(1,16):
        file1 = "XDATCAR"  # Replace with the first "XDTCAR" file name
        file2 = "XDATCAR"+str(i)  # Replace with the second "XDTCAR" file name
        output_file = "XDATCAR"  # Replace with the desired output file name


        configurations1 = read_xdtcar(file1)
        configurations2 = read_xdtcar(file2)

        concatenated_configurations = configurations1 + configurations2

        with open(file2, "r") as f1:
            header_info = "".join(f1.readline() for _ in range(7))  # Save the first 7 lines as the header

        write_xdtcar(header_info, concatenated_configurations, output_file)
