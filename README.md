# spike-linux-kernel
spike'ta opensbi üzerinde linux kerneli çalıştırmak

## İçerik

  - [İçerik](#i̇çerik)
  - [Özet](#özet)
    - [Payload ve Kernel](#payload-ve-kernel)
    - [İnitramfs](#i̇nitramfs)
    - [Simülasyon](#simülasyon)
    - [Arka Planda Neler Oluyor](#simülasyon)
  <!-- - [faaydalı linkler](#) -->
  - [Sözlük](#sözlük)

## Giriş

Bu belge spike'ta (riscv-isa-sim) opensbi ile linux kernel'i çalıştırmak ve bunların üzerinde bir user-space program çalıştırmak hakkında bir reherdir.
***
***
> Bu bege boyunca firmware ve opensbi (open supervisor-binary-interface) terimleri birbirinin yerine kullanılmıştır. 

RISCV software stack'te platform (machine) ile kernel (supervisor) arasında yer alan protokole supervisor binary interface denir. opensbi bu protokolün bir gerçeklemesidir. Firmware olarak isimlendirilmemizin sebebi, ilk çalışmaya başlayan ve platformun ilklendirilmesiyle ilgili düşük seviyeli işlemleri yapan yazılım olmasıdır. Aynı zamanda opensbi dokümantasyonlarında da bu isimle (firmware) anılmaktadır.
***
Firmware, spike'a bir `<target program>` olarak verilir. spike, platform'la ilgili birkaç basit parametrenin geçilmesinden ibaret olan stage-0 boot işlemini yaptıktan sonra firmware'i başlatır.
***
***
linux kernel, opensbi firmware'ine kendi dokümantasyonlarında bahsedildiği gibi bir "payload" olarak gömülecektir. firmware, platformu ilklendirdikten sonra linux kernel'i boot'layacaktır.
***
kernel boot edildikten sonra initramfs'in (initial ram file system) bulunduğu initrd'yi (initial ram-disk) mount'layacaktır. Aslında bu aşamada gerçek dünyada initrd yerine doğrudan, veya initrd bir ara basamak olup sıradaki basamak olarak (root-file-system'in bulunduğu) kalıcı bir bellek mount'lanabilir fakat spike'ta kalıcı bir bellek canlandırılmadığı için yolumuza initramfs ve initrd ile devam edeceğiz. 
***
***
initrd mountlandıktan sonra, Bir shell arayüzü çıkar. Buradan daha önce initramfs'e yerleştirdiğimiz user-space uygulama deneyebiliriz.
***
Bu shell arayüzü busybox tarafından sağlanır. busybox temel linux komutlarını sağlayan bir user-space uygulamadır.

## Özet



### Payload ve Kernel
`riscv64-unknown-linux-gnu-` derleyicisiyle

  - linux kernel `Image`
  - `Image`'ı kullanarak opensbi'ın `fw_payload`'ını (firmware with payload)

derliyoruz.

### İnitramfs

yine `riscv64-unknown-linux-gnu-` derleyicisiyle,

  - `busybox`'ı `-static` olarak derleyip bir `initramfs` (initial ram file system) dizini oluşturuyoruz.

  - Simülasyonda çalıştırmak istediğimiz programları yine `-static` olarak derleyip `initramfs`'in içine koyuyoruz. 


initramfs dizinden `cpio` ile `initramfs.cpio` binary'sini elde ediyoruz.

### Simülasyon

`spike`'a `<target program>` olarak `fw_payload`'ı ve `--initrd` olarak `initramfs.cpio`'yu ve `--bootargs`'ı (kernel boot arguments) verip çalıştırıyoruz. 

opensbi firmware ve kernel tarafından gerekli ilklendirmeler yapıldıktan sonra önümüze `busybox` tarafından sağlanan bir shell geliyor. Bu shell ile `busybox` tarafından sağlanan `cat`, `ls`, `cd`, `mkdir`, `mount` ve daha bir çok primitive linux komutlarını çalıştırabilir ve [initramfs](#initramfs)<!--linki detaylı açıklamanın olduu kısma ver--> aşamasında initramfs dizininin içine yerleştirdiğimiz dosyalarla etkileşebiliriz. 

### Arka Planda Neler Oluyor
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

## Kurulum

### Ön Gereksinimler

  - `riscv64-unknown-linux-gnu-xxx` ailesi ([toolchain oluşturma](toolchain_olusturma.md))
  - spike

### Linux Kernel Derleme

```shell
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
make ARCH=riscv defconfig
make -j8 ARCH=riscv CROSS_COMPILE=riscv64-unknown-linux-gnu-
```

<!-- kernelin derlenmiş halini koy -->

<!-- buraya oluşan çıktılar hakkında kısaca bilgi ver, neden Image'i kullandığımız hakında fikir vermek için -->

### Firmware

```shell
git clone https://github.com/riscv-software-src/opensbi
cd opensbi
make -j8 PLATFORM=generic CROSS_COMPILE=riscv64-unknown-linux-gnu- FW_TEXT_START=0x80000000 FW_PAYLOAD_PATH=../linux/arch/riscv/boot/Image
```

<!-- bunları açıkla -->

`FW_FDT_PATH` 
`FW_FDT_ADDR` 
`FW_FDT_OFFSET` 
`FW_PAYLOAD_PATH` 
`FW_PAYLOAD_ADDR` 
`FW_PAYLOAD_OFFSET`
`PLATFORM`

build'in altındaki fw_payload.elf.ld silinmeden `FW_TEXT_START` etkili olmuyor.

### Initrd ve Initramfs

#### Busybox



## Sözlük
yazılacak
