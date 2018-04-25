cpp -nostdinc -Iinclude -Idts -undef -x assembler-with-cpp dts-min/tegra210-hac-001.dts > tmp.dts
dtc -O dtb -o tegra210-hac-001.dtb tmp.dts

