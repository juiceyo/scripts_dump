## This script will take a text file of IP addresses and names, and convert it to an XML file for use in xml config.
## input_file must be in the format of name SPACE ip. Example: googledns1 1.1.1.1

def convert_to_xml(input_file, output_file):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    xml_content = '<Settings>\n'
    
    for line in lines:
        name, ip = line.strip().split()
        xml_content += f'    <Setting name="{name}" value="{ip}" />\n'
    
    xml_content += '</Settings>'

    with open(output_file, 'w') as file:
        file.write(xml_content)

    print(f"XML file '{output_file}' generated successfully.")

convert_to_xml('ips.txt', 'settings.xml')
