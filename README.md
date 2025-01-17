# spike-linux-kernel
spike'ta opensbi üzerinde linux kerneli çalıştırmak

## İçerik

  - [içerik](#i̇çerik)
  - [özet](#özet)
    - [payload ve kernel](#payload-ve-kernel)
    - [initramfs](#initramfs)
    - [simülasyon](#simülasyon)
  <!-- - [faaydalı linkler](#) -->
  - [sözlük](#sözlük)

## Özet

### payload ve kernel
`riscv64-unknown-linux-gnu-` derleyicisiyle

  - linux kernel `Image`
  - `Image`'ı kullanarak opensbi'ın `fw_payload`'ını (firmware with payload)

derliyoruz.

### initramfs

yine `riscv64-unknown-linux-gnu-` derleyicisiyle,

  - `busybox`'ı `-static` olarak derleyip bir `initramfs` (initial ram file system) dizini oluşturuyoruz.

  - Simülasyonda çalıştırmak istediğimiz programları yine `-static` olarak derleyip `initramfs`'in içine koyuyoruz. 


initramfs dizinden `cpio` ile `initramfs.cpio` binary'sini elde ediyoruz.

### simülasyon

`spike`'a `<target program>` olarak `fw_payload`'ı ve `--initrd` olarak `initramfs.cpio`'yu ve `--bootargs`'ı (kernel boot arguments) verip çalıştırıyoruz. 

opensbi firmware ve kernel tarafından gerekli ilklendirmeler yapıldıktan sonra önümüze `busybox` tarafından sağlanan bir shell geliyor. Bu shell ile `busybox` tarafından sağlanan `cat`, `ls`, `cd`, `mkdir`, `mount` ve daha bir çok primitive linux komutlarını çalıştırabilir ve [initramfs](#initramfs)<!--linki detaylı açıklamanın olduu kısma ver--> aşamasında initramfs dizininin içine yerleştirdiğimiz dosyalarla etkileşebiliriz. 

### arka planda neler oluyor
`spike`, 
  - `initramfs.cpio`'yu simülasyon belleğine `initrd` olarak yüklüyor. 
  - `device tree blob`'u oluşturuyor.
    - bunda, `initrd`nin konumu
    - `bootargs`
    - çevrebirimler 
    - bellek haritası 

    gibi bilgiler var.
  
  - stage-0 boot işlemini yapıyor. 
    - a0 <- hartid
    - a1 <- device tree blob address
    - stage-1 boot'u yani `<target program>`'ı (`fw_payload`) başlat
<!-- ## faydalı linkler -->

`fw_payload`, firmware kısmı (opensbi) ilklendirmelerini yaptıktan sonra kontrolü içinde gömülü olan (bkz. [payload ve kernel](#payload-ve-kernel)<!--linki detaylı açıklamanın olduu kısma ver-->) kernel'e devrediyor. 

Kernel, üzerine düşen ilklendirme işlemlerini yapıyor ve en sonunda `initrd`'teki  `busybox`'un shell'i başlatılıyor.

## Sözlük
yazılacak
