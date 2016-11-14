ALICE OCDB lists
================

This repository contains a versioned pointer of the ALICE OCDB files in a given
moment in time. Every tag of this repository represents a snapshot of the OCDB.

Take a new OCDB snapshot
------------------------

Enter an AliEn environment, get a token and take the snapshot:

    alienv enter AliEn-Runtime/latest
    alien-token-init <your_user_name>
    ./take_snapshot.sh [file_name]

If `file_name` is not specified it defaults to `ocdb_list.txt`.

The snapshot will be created in the current Git-versioned directory. Commit it,
and tag if appropriate:

    git add ocdb_list.txt
    git commit -m "OCDB list from $(date +%Y-%m-%d)"
    git tag v$(date +Y%m%d)-r1
    git push --tags

Compact to full list
--------------------

The list is compressed in a simple format:

    /alice/path/prefix:
    0_999999999_v1_s0
    0_999999999_v2_s0
    /alice/path/prefix/subprefix:
    0_123456_v1_s0
    ...

All entries following a label (line ending with `:`) are supposed to be prefixed
with the last label found. OCDB files have their initial `Run` and final `.root`
stripped. Those strategies are applied in order to save some space by removing
repeated information. To convert the compact list to a list of full paths:

    ./compact-to-full.sh [file_name]

If `file_name` is not specified it defaults to `ocdb_list.txt`.

> Do not compress the resulting `ocdb_list.txt`. Text files and differences are
> stored efficiently by Git.
