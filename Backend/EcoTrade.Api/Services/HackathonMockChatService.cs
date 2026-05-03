using System.Globalization;

namespace EcoTrade.Api.Services;

/// <summary>Jüri demosu (hackathon MVP): anahtar kelimeye göre hazır Türkçe yanıtlar.</summary>
public sealed class HackathonMockChatService : IHackathonChatService
{
    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public string BuildReply(string userMessage)
    {
        var raw = userMessage.Trim();
        if (raw.Length == 0)
        {
            return "Mesaj boş olamaz — kısa bir soru yazabilirsin.";
        }

        var t = raw.ToLower(Tr);

        // Jüriyi etkileyecek basit anahtar kelime mantığı (hackathon senaryosu)
        if (Contains(t, "rapor") || Contains(t, "aylık") || Contains(t, "aylik"))
        {
            return "Tabii. Son 3 günde toplam 14.2 kWh enerji ürettin. Bunun 8.6 kWh'sini havuza satarak 18.50 ₺ net kazanç sağladın.";
        }

        if (Contains(t, "alarm") || Contains(t, "fiyat"))
        {
            return "Fiyat alarmı kuruldu! DEDAŞ fiyatı 2.50 ₺'yi geçtiğinde sana bildirim göndereceğim.";
        }

        if (Contains(t, "tasarruf") || Contains(t, "ipucu"))
        {
            return "Şu an havuz fiyatı DEDAŞ'tan %40 daha ucuz. Çamaşır veya bulaşık makinesini şimdi çalıştırmak harika bir fikir.";
        }

        if (Contains(t, "tahmin") || Contains(t, "üretim") || Contains(t, "uretim") || Contains(t, "güneş") || Contains(t, "gunes"))
        {
            return "Anlık tahmin servisimiz Düzce pilot meteorolojisini kullanıyor; öğlen çevresinde üretim genelde zirve yapıyor. "
                   + "Grafikteki ‘Şu an’ dilimi güncelleniyor — bir sonraki 6 saatlik eğriyi Üretici tahmini kartından takip edebilirsin.";
        }

        if (Contains(t, "satış") || Contains(t, "satis") || Contains(t, "satmak"))
        {
            return "Komşu talebi yüksekken fazla enerjiyi EcoTrade havuzunda dinamik fiyat ipucu ile sunmak "
                   + "genelde daha iyi netleştirir. En iyi satış saati kartına ve Borsa sekmesine göz at.";
        }

        if (Contains(t, "merhaba") || Contains(t, "selam") || Contains(t, "hey"))
        {
            return "Merhaba — ben EcoTrade asistanıyım. Tahmin, satış penceresi ve havuz fiyatları için sorabilirsin.";
        }

        if (Contains(t, "yardım") || Contains(t, "help") || Contains(t, "nasıl"))
        {
            return "EcoTrade ile mahalle içi yenilenebilir enerji ticareti: Ana sayfa üretim/tüketim, Borsa fiyat, Yapay zeka sohbet. "
                   + "‘rapor’, ‘fiyat’, ‘tasarruf’ gibi kelimelerle dene.";
        }

        return "EcoTrade Asistanı olarak şu an hackathon simülasyonundayım. Verilerinizi analiz ediyorum.";
    }

    private static bool Contains(string haystack, string needle) =>
        haystack.Contains(needle, StringComparison.Ordinal);
}
