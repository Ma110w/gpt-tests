from ftplib import FTP

ftp = FTP('ftp.maps.canada.ca')
ftp.login()  # anonymous login
ftp.cwd('/pub/nrcan_rncan/elevation/cdsm_mnsc/')

files = []
ftp.retrlines('LIST', files.append)

for file in files:
    print(file)
