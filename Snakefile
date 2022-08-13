from glob import glob
import os

ALL_MAGS = list(glob("outputs/mags/*.fna"))

rule all:
  input:
    'inputs/tara_runinfo.csv',
    'inputs/parks_runinfo.csv',
    'inputs/tully_mag_stats.xlsx',
    'inputs/tully_mag_taxonomy.xlsx',
    #expand("outputs/sigs/{mag}.sig", mag=[os.path.basename(m) for m in ALL_MAGS])

rule download_tara_runinfo:
  output: 'inputs/tara_runinfo.csv'
  shell: """
    esearch -db sra -query '"173486"[bioproject]' | efetch -format runinfo > {output}
  """

rule download_parks_8k:
  output: "inputs/parks_runinfo.csv"
  shell: """
    esearch -db sra -query '"348753"[bioproject]' | efetch -format runinfo > {output}
  """

rule download_article_tables_stats:
  output: "inputs/tully_mag_stats.xlsx"
  shell: "wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fsdata.2017.203/MediaObjects/41597_2018_BFsdata2017203_MOESM89_ESM.xlsx' -O {output}"

rule download_article_tables_taxonomy:
  output: "inputs/tully_mag_taxonomy.xlsx"
  shell: "wget 'https://static-content.springer.com/esm/art%3A10.1038%2Fsdata.2017.203/MediaObjects/41597_2018_BFsdata2017203_MOESM90_ESM.xlsx' -O {output}"

rule compute:
  output: "outputs/sigs/{mag}.fna.sig"
  input: "outputs/mags/{mag}.fna"
  conda: "env/sourmash.yml"
  shell: """
    sourmash compute \
        -k 21,31,51 \
        --scaled 1000 \
        --track-abundance \
        --name {wildcards.mag} \
        -o {output} \
        {input}
  """
