#!/bin/bash

read -p "initramfs olarak ayarlanacak dizini \
girin (varsayilan: initramfs): " initramfs_dir
initramfs_dir=${initramfs_dir:-initramfs}  # If empty, set default to "initramfs"


initramfs_taslak_script="./initramfs_taslak_olustur.sh"

if [ -d $initramfs_dir ]; then
  read -p "$initramfs_dir dizini daha once olusturulmus. uzerine yazmak \
  ister misiniz (!$initramfs_dir'de yaptiginiz degisiklikleri \
  kaybedebilirsiniz)? (y/N): " secim

  case "$secim" in
    [yY] )
      $initramfs_taslak_script $initramfs_dir
      echo "mevcut $initramfs_dir dizininin uzerine yazildi."
      ;;
    * )
      echo "mevcut $initramfs_dir dizini ile devam ediliyor."
      ;;
  esac
else
  echo "$initramfs_taslak_script $initramfs_dir komutu calistiriliyor."
  $initramfs_taslak_script $initramfs_dir
  echo "initramfs dizini olusturuldu."
fi

initramfs_home_dir=$initramfs_dir/home/user1
echo "$initramfs_home_dir dizini olusturuldu"

mkdir -p $initramfs_home_dir
echo "simulasyon sirasinda kullanmak istediginiz dosyalarin path'lerini \
giriniz."
echo "bu dosyalar $initramfs_home_dir dizinine kopyalanacaktir."
echo "calistirmak istediginiz programlar, riscv-unknown-linux-gnu-xxx \
-static olarak derlenmis olmalilar."
echo "bu islemi su an manuel olarak yaptiysaniz bu adimi gecebilirsiniz."

read -p " kopyalanacak dosyalar: " kopyalanacak_dosyalar

if [ -n "$kopyalanacak_dosyalar" ]; then
    cp -r -t $initramfs_home_dir $kopyalanacak_dosyalar
fi


cd $initramfs_dir
find . | cpio -o --format=newc > ../$initramfs_dir.cpio
cd ..

initramfs_boyut_byte=$(wc -c < $initramfs_dir.cpio)

# INITRD_START ve INITRD_END kelimeleri geciyor mu diye kontrol et,
# gecmiyorsa hata mesaji verip bitir.
dts_taslak=taslak.dts

if ! grep -q "INITRD_START" "$dts_taslak" \
|| ! grep -q "INITRD_END" "$dts_taslak"; then
  echo "Hata: INITRD_START veya INITRD_END \
  kelimeleri $dts_taslak dosyasi içinde bulunamadi."
  echo "taslak dts dosyanizda soyle bir bolum bulundugundan emin olun:"
  echo  "/dts-v1/;"
  echo  ""
  echo  "  / {"
  echo  "  // diger satirlar"
  echo  "  chosen {"
  echo  "      stdout-path = &SERIAL0;" // farkli olabilir?
  echo  "      linux,initrd-start = <INITRD_START>;"
  echo  "      linux,initrd-end = <INITRD_END>;"
  echo  "      bootargs = "root=/dev/ram rw console=ttyS0 earlycon=sbi";"\
  // farkli olabilir?
  echo  "  };"
  echo  "  // diger satirlar"
  echo  "  };"
  exit 1
fi

initrd_start_deger=0xf0d7be00
initrd_end_deger=$((initrd_start_deger + initramfs_boyut_byte))
initrd_end_deger=$(printf "0x%x" $initrd_end_deger)
# initrd_end_deger'yu hex'e cevir.
# $dts_taslak'teki INITRD_START'yi $initrd_start_deger ile degistir, 
# INITRD_END'i $initrd_end_deger ile degistir.
# dts.dts diye bir dosya olustur.

dts_son="dts.dts"
cp "$dts_taslak" "$dts_son"

# INITRD_START'ı ve INITRD_END'i güncelle
sed -i "s/INITRD_START/$initrd_start_deger/g" "$dts_son"
sed -i "s/INITRD_END/$initrd_end_deger/g" "$dts_son"

dtc -I dts -O dtb -o dtb.dtb dts.dts

fw_text_start=0x80000000
fw_initram_offset=$((initrd_start_deger - fw_text_start))
fw_initram_offset=$(printf "0x%x" $fw_initram_offset)

cd opensbi

rm -rf build/platform/generic/firmware/fw_payload.elf.ld

make_cmd="make FW_DYNAMIC=n FW_JUMP=n FW_PAYLOAD=y \
  CROSS_COMPILE=riscv64-unknown-linux-gnu- \
  PLATFORM=generic FW_FDT_PATH=../dtb.dtb \
  FW_PAYLOAD_PATH=../Image \
  FW_INITRAM_PATH=../$initramfs_dir.cpio \
  FW_INITRAM_OFFSET=$fw_initram_offset \
  FW_TEXT_START=$fw_text_start -j16"

eval $make_cmd

if [ $? -ne 0 ]; then
  echo "opensbi build'leme basarisiz oldu. build dizini \
  temizlenip yeniden deneniyor."
  rm -rf build/*
  eval $make_cmd
fi

cp build/platform/generic/firmware/fw_payload.elf ../

cd ..

spike opensbi/build/platform/generic/firmware/fw_payload.elf
