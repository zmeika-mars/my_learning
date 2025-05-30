def mess_list(output_val, *other_val):
    for str_log_1 in other_val:
        str_log = str_log_1.split()
        val_time = ' '.join(str_log[0:3])
        val_pcname = str_log[3]
        val_service = str_log[4].strip(':')
        val_messages = ' '.join(str_log[5:])
        dict_1 = {'time': val_time, 'pc_name': val_pcname, 'service_name': val_service, 'message': val_messages}
        output_val.append(dict_1)

logs = []

mess_list(
    logs,
    "May 18 11:59:18 PC-00102 plasmashell[1312]: kf.plasma.core: findInCache with a lastModified timestamp of 0 is deprecated",
    "May 18 13:06:54 ideapad kwin_x11[1273]: Qt Quick Layouts: Detected recursive rearrange. Aborting after two iterations.",
    "May 20 11:01:12 PC-00102 PackageKit: daemon start"
          )

for log in logs:
    print(log)


availiable_size = [
    {'id': 382, 'total': 999641890816, 'used': 228013805568},
    {'id': 385, 'total': 61686008768, 'used': 52522710872},
    {'id': 398, 'total': 149023482194, 'used': 83612310700},
    {'id': 400, 'total': 498830397039, 'used': 459995976927},
    {'id': 401, 'total': 93386008768, 'used': 65371350065},
    {'id': 402, 'total': 988242468378, 'used': 892424683789},
    {'id': 430, 'total': 49705846287, 'used': 9522710872},
]

def analyze_disks(availiable_size):
    dict_disk = {'memory_ok': [] ,'memory_not_enough': [],'memory_critical': []} 
    for disk in availiable_size:
        total_size = (disk.get('total'))
        used_size = (disk.get('used'))

        used_space_per = (100 - ((used_size/total_size) * 100 ))
        usable_space = (total_size-used_size)
        usable_space_gb = (usable_space / (1024 ** 3))

        if usable_space_gb <= 10 or used_space_per <= 5:
            {dict_disk['memory_critical'].append(disk['id'])}
        elif usable_space_gb <= 30 or used_space_per <= 10:
            {dict_disk['memory_not_enough'].append(disk['id'])}
        else:
            {dict_disk['memory_ok'].append(disk['id'])}
        
    return dict_disk

print(analyze_disks(availiable_size))