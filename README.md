# SQL Server: Index 
Veritabanları milyonlarca kayıt içerebilir. Bu veriler arasından, belirli şartlarda verileri hatta veriyi bulmak, tabloadaki veriler rasgele sıralanmışsa çok zaman alabilir. Örneğin Trendyol, son zamanların en çok konuşalun ve kullanılan e-ticaret sitesi değil mi? Veri tabanında kaç milyon kayıt vardır kim bilir. Müşterilerden ismi 'Yi' ile başlayan kişilere kampanya tanımlanacağını düşünelim. Milyonluk kayıtlarda, isim başlangıcı 'Yi' ile başlayan kayıtları bulmak istersek, tablodaki tüm kayıtların tek tek taranması gerekir. Çok verimsiz, gereksiz yere veri tabanını kilitleyen bir işlem olur. 

Index dediğimiz yapılar, bu sorunu çözmek için tasarlanmıştır. Bu yapılar, tablodaki verileri belirli bir sütun(CUSTOMER_NAME) veya sütunları sıralanmış bir biçimde tutar. Bize kolaylığı ne oluyor? Belirli bir veriyi bulamk için tablodaki tüm kayıtları taramak yerine, index taramamız yeterli olacaktır. Çok daha hızlı ve verimli bir işlem. Gerçek hayat örneği vererek konumuzu bir pekiştirelim, neden index ihtiyacımız var(:?

Atatürk filmini izlemek için sinemaya gittiniz. Aldığınız bilet, Salon 6 koltuk E4 diyelim. Film saati yaklaşınca ne yapıyorsunuz? Salon 6'ya gidiyorsunuz, E bloğu buluyorsunuz ardından 4 numaralı koltuğu bulup oturuyorsunuz değil mi? Her salonun, bloğun koltuğun yeri belli, istediğinizi direkt olarak zorlanmadan bulabiliyorsunuz. Eğer bu bilgiler kapılarda, koltuklarda olmasaydı ne olurdu? Bir düşünün, tüm salonlara girip tek tek yer aramanız gerekecekti, sinir bozucu, şahsen vaktimin kaybolmasını istemem.

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
person tablosundaki salary kolonunu en küçükten en büyüğe olacak şekilde sıralatıyoruz.İlerleyen başlıklarda daha detaylı bir şekilde ele alacağız

Peki bu index ile ne yapacağız? Nereden gözlemleyeceğiz? Hepsi sırayla. Öncelikle sistem tarafından gelen bir Stored Procedure'müz mevcut, sp_Helpindex. Person tablosunda varolan, indexleri ve key değerlerini görmek için sp_Helpindex'i tetikliyoruz. Index keyden kastımız, index oluştururken belirttiğimiz kolondur, az önce oluşturduğumuz index'te Salary'di. Şimdi bunları görelim;

```sql
sp_Helpindex Person;
```
![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/b205305a-e34d-41ff-a073-82c58224d3c5)

tetiklediğim anda yukarıdaki çıktı karşıma geldi. Index'e vermiş olduğum isim, key değeri ve description. Name ve key değerleri tamam bence ama description alanında 'nonclustered located on PRIMARY' yazıyor, ne anlama geliyor acaba? başka türleri var mı? Ama önce bir index silme işlemi yapalım. 

Eğer hatalı oluşturma gerçekleştiyse, index silebiliyoruz. Index oluşturduğunuz tablo ve index ismini yazarak, drop işlemini gerçekleştirebilirsiniz.

```sql
DROP INDEX Person.IX_Person_Salary;
```
![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/4fecdd6a-98d4-4581-b431-0c8703240687)

query çalıştıktan sonra sistem tarafından hazırlanan SP'yi tekrardan tetikliyorum.

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/33ee1056-49a1-4562-9efa-6acacd471d1c)

Artık Person tablosunda herhangi bir index olmadığını bana söylüyor.


# Clustered Index

Bir tablodaki verileri fiziksel olarak nasıl saklandığını ve düzenlendiğini belirleyen bir index olarak geçmektedir.  Clustered index oluşunca, tablodaki tüm veriler bir sıraya konur. Fiziksel olarak bir düzenleme geçerli olduğu için, clustered index seçeceğimiz kolon; sorgularda en fazla kullanılan ve çok fazla değişiklik yapılmayan kolon olması performans açısından pozitif katkıda bulunuacaktır. Neden? Eğer yeni bir veri gelirse, fiziksel olarak yeniden sıralama durumu gerçekleşecektir.

Önceki örneğimde kullandığım tüm tabloları dropladım, yeni tablo ve veriler üzerinden çalışacağım. Mockarro sitesinden mock dataları alacağım, bu site sayesinde istediğiniz kadar insert sorguları oluşturabiliyorsunuz. Kod örneklerini repo içerisinde zaten paylaşıyor olacağım.
!!! link gelecek

Tablo oluşturup içerisine mock datalarımı insert ediyorum.

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/57ef8d8f-9e24-45f0-af0e-ce8313ec0d2b)

Yukarıdaki resimden görebileceğiniz gibi tablomda 100 adet kayıt var. Kayıtlar üzerinde herhangi bir sıralama mevcut değil, id kısmında olan sıralama, insert sorgularını sıralı olarak 1'den 100'e kadar çalıştırmamdan kaynaklı.

Şimdi person tablosu üzerinde bir clustered index oluşturalım ve bakalım gerçekten veriler fiziksel olarak sıralanıyor mu? Email değeri üzerinde oluşturacağım.

```sql
CREATE CLUSTERED INDEX IX_CLUSTERED_PERSON_EMAIL
ON PERSON (email);
```

Hemen select atıyorum vee;

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/2c96b0aa-3964-485d-bbee-29db1145149c)

emailler a'dan z'ye olacak şekilde sıralanmış. Gerçektende fiziksel olarak sıralama işlemi gerçekleşiyormuş. Peki yeni kayıt gelince ne oluyor?

```sql
INSERT INTO Person (id, first_name, last_name, email) VALUES (101, 'Alex', 'Souza', 'alex10souza@outlook.com');
```
![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/eaeadaf7-de2f-4c09-bd45-089a10fff0d6)

Attığım kayıt sonrasında, index yeniden düzenlendi ve fiziksel olarak yeniden sıralandı.

Tablo oluştururken Id değerine primary key vermediğimi söylemiştim. Şimdi bu konuyu ele alalım, yeni bir tablo oluşturuyorum.

```sql
CREATE TABLE Student(
id int primary key,
first_name varchar(255)
);
```
Hemen ardından ise 

```sql
sp_Helpindex Student;
```

tabloda herhangi bir index var mı yok mu kontrol ediyorum, derken?;

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/af32a91c-eeb5-4fd2-bdfa-14ebf240c1c4)

index oluşmuş. Id kolonunu primary key olarak atadığım için clustered bir şekilde index tanımlamış. Ne anlama geliyor?
Id değeri küçükten büyüğe olacak şekilde sıralanacaktır. Sırayla insert atıyorum ve kontrol ediyorum.

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/65c5825b-2e1a-4c44-8c66-5deb0a315a6b)

Id değerine göre fiziksel olarak sıralandığını görüyorum.

Kısa bir özet geçelim;
* Sorgu performansım iyileşti, fiziksel olarak sıralanan verilerden hızlıca aradıklarımı bulabildim. Veriler daha kolay erişilebilir hale gelmiş oldu.
* Dezavantajımız da var tabloya gelecek olan güncellemeler yavaşlayabilir. Veri güncellenmesi veya eklenmesi ardından, verilerin fiziksel olarak yeniden sıralanması gerekmektedir. Bu işlemler haliyle, güncelleme işlemlerini yavaşlatabilir.

# NonClustered Index
Non-clustered, clustered'ın aksine verileri fiziksel olarak sıralamak yerine, mantıksal olarak sıralar. 

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/98c49232-4ed4-4324-8b2e-9dc123455dab)

Non clustered index'e eklenen kolonlar, tablodan bağımsız olarak diskte ayrı bir şekilde tutulur. Haliyle ekstra yer kaplarlar. Tabloda çok fazla non-clustered index varsa, her ekleme,silme, güncelleme işleminde tablonun haricinde bu tablodaki bütün non clustered index’lere de uygulanacağı için ekleme,silme, güncelleme performansı yavaşlayacaktır.

Person tablom üzerindne devam ediyorum. Eklediğim indexleri siliyorum, index olmadığına emin oluyorum. Ardından non-clustered index oluşturma işlemine geçiyorum.

```sql
CREATE NONCLUSTERED INDEX IX_PERSON_EMAIL ON Person (email DESC);
```

Person tablosunun, email alanında Z'den A'ya olacak şekilde bir sıralama gerçekleştirmesini istedim. Hemen bir select atalım.

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/cfe81c98-c2ab-4737-a202-a78cfc6a8812)

Fiziksel olarak herhangi bir değişiklik olmadı. Peki non-clustered bize ne sağladı? 

![image](https://github.com/yigitcanolmez/sql-index-exp/assets/90285509/d51301f2-8928-48b5-8f22-d1f5ec6dd0f3)

Yukarıdaki resimde görebileceğiniz bir mantık var, 95 sayısını ele alalım. 1-200 aralığını tutan bir Root Node mevcut. Bu Node değerlerini takip ederek, ilgili dataya ulaşmaktadır. Verileri küçük parçalara ayırdık, veri arama işlemlerini hızlandırdık.

