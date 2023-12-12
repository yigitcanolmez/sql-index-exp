# SQL Server: Index 
Veritabanları milyonlarca kayıt içerebilir. Bu veriler arasından, belirli şartlarda verileri hatta veriyi bulmak, tabloadaki veriler rasgele sıralanmışsa çok zaman alabilir. Örneğin Trendyol, son zamanların en çok konuşalun ve kullanılan e-ticaret sitesi değil mi? Veri tabanında kaç milyon kayıt vardır kim bilir. Müşterilerden ismi 'Yi' ile başlayan kişilere kampanya tanımlanacağını düşünelim. Milyonluk kayıtlarda, isim başlangıcı 'Yi' ile başlayan kayıtları bulmak istersek, tablodaki tüm kayıtların tek tek taranması gerekir. Çok verimsiz, gereksiz yere veri tabanını kilitleyen bir işlem olur. 

Index dediğimiz yapılar, bu sorunu çözmek için tasarlanmıştır. Bu yapılar, tablodaki verileri belirli bir sütun(CUSTOMER_NAME) veya sütunları sıralanmış bir biçimde tutar. Bize kolaylığı ne oluyor? Belirli bir veriyi bulamk için tablodaki tüm kayıtları taramak yerine, index taramamız yeterli olacaktır. Çok daha hızlı ve verimli bir işlem. Gerçek hayat örneği vererek konumuzu bir pekiştirelim, neden index ihtiyacımız var(:?

Atatürk filmini izlemek için sinemaya gittiniz. Aldığınız bilet, Salon 6 koltuk E4 diyelim. Film saati yaklaşınca ne yapıyorsunuz? Salon 6'ya gidiyorsunuz, E bloğu buluyorsunuz ardından 4 numaralı koltuğu bulup oturuyorsunuz değil mi? Her salonun, bloğun koltuğun yeri belli, istediğinizi direkt olarak zorlanmadan bulabiliyorsunuz. Eğer bu bilgiler kapılarda, koltuklarda olmasaydı ne olurdu? Bir düşünün, tüm salonlara girip tek tek yer aramanız gerekecekti, sinir bozucu, şahsen vaktimin kaybolmasını istemem.

Trendyol örneğimize geri dönelim, müşteri isimleri belirli bir sırayla sıralanmışlarsa 'Yi' ile başlayan isimleri bulmak kolaylaşır, belirli sıradan kastım ise harflere göre diyebiliriz. Tek harf için pek sorun teşkil etmez ama, iki harf için çok fazla kombinasyon doğuyor, çok karmaşık bir yapı olur buraya ilerleyen konularda değineceğim.

Uygulamalı örneklere başlayalım; bir adet tablo oluşturalım.

```sql

-- TABLO OLUŞTURMA

CREATE TABLE Person(
Id int,-- tabi normalde int olarak tutulmaz ama örnek olduğu için int ile ilerliyorum
FirstName varchar(255),
LastName varchar(255),
Salary int --tam sayı olarak almak istediğim için integer verdim.
);

SELECT * FROM Person; --tablonun oluştuğunu görelim

--şimdide içerisine kayıt atalım

INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (1, 'Yiğitcan', 'Ölmez', '1907');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (2, 'Mert', 'Ölmez', '2800');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (3, 'Edin','Dzeko', '3200');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (4, 'Sebastian', 'Szymanski', '2700');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (5, 'Dusan', 'Tadic', '5500');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (6, 'Dominik', 'Livakovic', '4000');
INSERT INTO Person (Id, FirstName, LastName, Salary) VALUES (7, 'Fred', 'Rodrigues', '3870');

-- atılan kayıtları görelim
SELECT * FROM Person;
```
Oluşturmuş olduğumuz tabloda herhangi bir index şuanlık bulunmamaktadır. Salary kolonuna bakarsanız zaten verilerin rastgele bir şekilde sıralanmış olduğunu anlayabilirsiniz. 
Şimdiki amacım, maaşı 2500 ile 3500 arasında olan kişileri bulmak. Hemen select sorgumu yazıyorum.

```sql
SELECT * FROM Person p WHERE Salary BETWEEN 2500 AND 3500;
```
Bu sorgu ile ben, tüm kayıtları dolaşarak, Salary değeri 2500 ve 3500 aralığında olan kayıtları direkt olarak getirdim. Az veri ile çalıştığımız için herhangi bir performans sorunu yaşamadık ama, milyonluk ve aktif olarak kullanılan bir tabloya böyle bir istek atarsanız sistemi yorar cevabın gelmesi uzun sürer.

Hadi o zaman ilk index'imizi oluşturalım.

```sql
CREATE INDEX IX_Person_Salary
on Person (Salary ASC); --IX prefix'i, index olduğunu belirtmek için kullanılmıştır.
```
person tablosundaki salary kolonunu en küçükten en büyüğe olacak şekilde sıralatıyoruz.

!!!!row information fotoğrafı koyulacka

Index artık oluştu, peki ne yapacağız? Nereden gözlemleyeceğiz? Hepsi sırayla. Öncelikle sistem tarafından gelen bir Stored Procedure'müz mevcut, sp_Helpindex. Person tablosunda varolan, indexleri ve key değerlerini görmek için sp_Helpindex'i tetikliyoruz. Index keyden kastımız, index oluştururken belirttiğimiz kolondur, az önce oluşturduğumuz index'te Salary'di. Şimdi bunları görelim;

```sql
sp_Helpindex Person;
```
![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/b205305a-e34d-41ff-a073-82c58224d3c5)

tetiklediğim anda yukarıdaki çıktı karşıma geldi. Index'e vermiş olduğum isim, key değeri ve description. Name ve key değerleri tamam bence ama description alanında 'nonclustered located on PRIMARY' yazıyor, ne anlama geliyor acaba? başka türleri var mı?
