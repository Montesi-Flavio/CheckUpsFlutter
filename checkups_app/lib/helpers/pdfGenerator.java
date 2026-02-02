package it.checkup.Helpers.PdfHelpers;

import it.checkup.CheckupMain;
import it.checkup.Models.ModelListe;
import it.checkup.Models.Tables.Oggetto;
import it.checkup.Models.Tables.Provvedimento;
import it.checkup.Models.Tables.Reparto;
import it.checkup.Models.Tables.Societa;
import it.checkup.Models.Tables.Titolo;
import it.checkup.Models.Tables.UnitaLocale;
import javafx.embed.swing.SwingFXUtils;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import javax.imageio.ImageIO;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.Rectangle;
import com.itextpdf.text.pdf.ColumnText;
import com.itextpdf.text.pdf.PdfContentByte;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPCellEvent;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfPageEventHelper;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;

public class pdfGenerator {

    // Variabile statica per tenere traccia del numero di pagina corrente
    public static int paginaAttuale;
    public static int pagineTotali;
    public static com.itextpdf.text.Image logoSocieta;
    public static String urlLogoCheckUps = CheckupMain.getLogoPath("LOGOCheckUp.jpg");
    public static String urlLogoCheckUpsPiccolo = CheckupMain.getLogoPath("LOGOCheckUpPiccolo.jpg");
    public static String revisione;
    public static String dataValutazione;

    // Metodo per generare un documento PDF per la valutazione dei rischi
    public static void stampaValutazioneRischi(Societa societa, UnitaLocale unitaLocale, List<Reparto> reparti,
            String nomeFile) {
        // Formatta la data
        SimpleDateFormat formatoIngresso = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat formatoUscita = new SimpleDateFormat("dd/MM/yyyy");

        // Importazione dei font custom
        FontFactory.register(CheckupMain.getFontPath("arial/ARIAL.TTF"),
                "ARIAL");
        FontFactory.register(CheckupMain.getFontPath("arial/ARIALBD.TTF"),
                "ARIAL_BOLD");
        FontFactory.register(CheckupMain.getFontPath("arial/ARIALBLACKITALIC.TTF"),
                "ARIAL_ITALIC");
        // Crea un nuovo documento con una dimensione personalizzata
        Document document = new Document(PageSize.A4.rotate(), 36, 36, 50, 36);
        paginaAttuale = 0;
        pagineTotali = 0;
        revisione = reparti.get(0).getRevisione();
        try {
            // Crea un'istanza di PdfWriter e imposta un piè di pagina personalizzato per il
            // documento
            PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(nomeFile));
            writer.setPageEvent(new PdfFooter());
            // Apre il documento
            document.open();
            // Creazione pagina iniziale
            PdfPTable tableIniziale = new PdfPTable(8);
            tableIniziale.setWidthPercentage(100);
            PdfPCell societaCellIniziale = createCell("Società/Ente: ", 1,
                    FontFactory.getFont("ARIAL", 10));
            tableIniziale.addCell(societaCellIniziale);
            PdfPCell nomeSocietaCellIniziale = createCell(societa.getNome(), 3,
                    FontFactory.getFont("ARIAL_BOLD", 10));
            tableIniziale.addCell(nomeSocietaCellIniziale);
            PdfPCell unitaLocaleCellIniziale = createCell("Un. Produttiva: ", 1,
                    FontFactory.getFont("ARIAL", 10));
            tableIniziale.addCell(unitaLocaleCellIniziale);
            PdfPCell nomeUnitaLocaleCellIniziale = createCell(unitaLocale.getNome(), 3,
                    FontFactory.getFont("ARIAL_BOLD", 10));
            tableIniziale.addCell(nomeUnitaLocaleCellIniziale);
            tableIniziale.setSpacingAfter(60f);
            // Aggiunge la tabella iniziale al documento e vado alla seconda pagina
            document.add(tableIniziale);

            // LOGO CHECKUPS
            PdfPTable tableLogoChekups = new PdfPTable(1);
            tableLogoChekups.setWidthPercentage(100);
            Image logoCopertina = Image.getInstance(urlLogoCheckUps);
            boolean isSocietaLogo = false;
            if (societa.hasImage()) {
                logoCopertina = javafxImageToPdfImage(societa.getLogoImage());
                isSocietaLogo = true;
            }
            if (isSocietaLogo) {
            logoCopertina.scaleToFit(1000, 320); // stessa altezza della cella
            }
            // Imposta le dimensioni dell'immagine
            PdfPCell logoChekups = createImageCell(logoCopertina, 1);
            logoChekups.setFixedHeight(320);
            logoChekups.setHorizontalAlignment(Element.ALIGN_CENTER);
            logoChekups.setVerticalAlignment(Element.ALIGN_MIDDLE);
            logoChekups.setBorder(Rectangle.NO_BORDER);
            tableLogoChekups.addCell(logoChekups);
            tableLogoChekups.setSpacingAfter(30f);
            document.add(tableLogoChekups);
            logoCopertina = Image.getInstance(urlLogoCheckUps);
            // SCRITTE SOTTO LOGO
            // Crea la tabella
            PdfPTable tableBody = new PdfPTable(1);
            tableBody.setWidthPercentage(100);

            // Crea il font principale (16 punti)
            Font fontGrande = FontFactory.getFont("ARIAL", 16);
            // Crea il font per la parte più piccola (14 punti, 2 punti in meno)
            Font fontPiccolo = FontFactory.getFont("ARIAL", 14);

            // Crea il testo con due parti: una con il font grande e una con il font piccolo
            Phrase phrase = new Phrase();
            phrase.add(new Chunk(
                    "Relazione Tecnica di Valutazione Rischi - \n in materia di salute e sicurezza sul lavoro D.Lgs. n. 81/2008 e s.m. e i. \n \n \n",
                    fontGrande));
            phrase.add(new Chunk("Firmano in data: ________________________ ", fontPiccolo));

            // Crea la cella e aggiungi il Phrase
            PdfPCell body = new PdfPCell(phrase);
            body.setHorizontalAlignment(Element.ALIGN_CENTER);
            body.setVerticalAlignment(Element.ALIGN_MIDDLE);
            body.setBorder(Rectangle.NO_BORDER);

            // Aggiungi la cella alla tabella
            tableBody.addCell(body);
            tableBody.setSpacingAfter(35f);

            // Aggiungi la tabella al documento
            document.add(tableBody);
            // Tabella contenente le firme
            PdfPTable tableUnderBody = new PdfPTable(2);
            PdfPCell underBodyLeft = createCell(
                    "Il Datore di Lavoro \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            PdfPCell underBodyRight = createCell(
                    "Il Rappresentante dei lavoratori per la sicurezza (RLS) \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyLeft.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyLeft.setVerticalAlignment(Element.ALIGN_MIDDLE);
            underBodyRight.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyRight.setVerticalAlignment(Element.ALIGN_MIDDLE);
            tableUnderBody.addCell(underBodyLeft);
            tableUnderBody.addCell(underBodyRight);
            tableUnderBody.setWidthPercentage(65);
            underBodyLeft = createCell(
                    "Il Responsabile del Servizio di Prevenzione e Protezione \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyRight = createCell(
                    "Il Medico Competente \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyLeft.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyLeft.setVerticalAlignment(Element.ALIGN_MIDDLE);
            underBodyRight.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyRight.setVerticalAlignment(Element.ALIGN_MIDDLE);
            tableUnderBody.addCell(underBodyLeft);
            tableUnderBody.addCell(underBodyRight);
            tableUnderBody.setSpacingAfter(40f);
            document.add(tableUnderBody);

            if (societa.hasImage()) {
                logoSocieta = javafxImageToPdfImage(societa.getLogoImage());
            }
            document.newPage();
            // Aggiungo l'indice
            aggiungiIndiceContenuti(document);
            document.newPage();
            int i = 0;
            // Itera attraverso i reparti per la valutazione dei rischi
            for (Reparto reparto : reparti) {
                writer.setPageEvent(new IntestazioneEvent(societa, unitaLocale, reparto));
                revisione = reparto.getRevisione();
                
                if (i != 0) {
                    document.newPage();
                }
                i++;
                if (reparto.getData().isPresent()) {
                    try {
                        // Parsing della data in arrivo
                        Date dataParsed = formatoIngresso.parse(reparto.getData().get().toString());
                        // Formattazione della data nel nuovo formato
                        dataValutazione = formatoUscita.format(dataParsed);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                } else {
                    try {
                        // Parsing della data in arrivo
                        Date dataParsed = formatoIngresso.parse("1900-01-01");
                        // Formattazione della data nel nuovo formato
                        dataValutazione = formatoUscita.format(dataParsed);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }


                // Filtra i titoli in base al reparto
                List<Titolo> titoli = ModelListe.filtraTitoliDaReparto(Collections.singletonList(reparto));

                // Ordino i titoli
                List<Titolo> titoliSorted = new ArrayList<>(titoli);
                Collections.sort(titoliSorted, (t1, t2) -> Integer.compare(t1.getPriorita(), t2.getPriorita()));

                // Itera attraverso i titoli
                for (Titolo titolo : titoliSorted) {
                    // All'inizio del ciclo per gli oggetti e i titoli, registra la posizione
                    // corrente nella pagina
                    float currentPosition = writer.getVerticalPosition(false);
                    currentPosition = writer.getVerticalPosition(false);
                    if (currentPosition < 430) {
                        document.newPage();
                    }
                    // Filtra gli oggetti in base al titolo
                    List<Oggetto> oggetti = ModelListe.filtraOggettiDaTitolo(titolo.getId());
                    // Ordino gli oggetti
                    List<Oggetto> oggettiSorted = new ArrayList<>(oggetti);
                    Collections.sort(oggettiSorted, (o1, o2) -> Integer.compare(o1.getPriorita(), o2.getPriorita()));
                    document.add(Chunk.NEWLINE);

                    int k = 0;
                    // Itera attraverso gli oggetti
                    for (Oggetto oggetto : oggettiSorted) {
                        currentPosition = writer.getVerticalPosition(false);
                        if (currentPosition < 150 && oggettiSorted.size() != k) {
                            document.newPage();
                        }
                        // Filtra le misure in base all'oggetto
                        List<Provvedimento> provvedimenti = ModelListe.filtraProvvedimentiDaOggetto(oggetto.getId());
                        // Ordino i provvedimenti
                        List<Provvedimento> provvedimentiSorted = new ArrayList<>(provvedimenti);
                        Collections.sort(provvedimentiSorted,
                                (p1, p2) -> Integer.compare(p1.getPriorita(), p2.getPriorita()));
                        // Salta se non ci sono misure per l'oggetto
                        if (provvedimentiSorted.size() == 0) {
                            continue;
                        }
                        // Controlla se è la prima iterazione per evitare interruzioni di pagina non
                        // necessarie
                        if (k == 0) {
                            // Titolo
                            PdfPTable tableTitolo = new PdfPTable(1);
                            // Creazione della cella per il titolo
                            PdfPCell cellaTitolo = new PdfPCell();
                            // Creazione del testo per la prima parte (Arial Bold)
                            Chunk parte1 = new Chunk("Titolo: ", FontFactory.getFont("ARIAL", 12));
                            // Creazione del testo per la seconda parte (Arial)
                            Chunk parte2 = new Chunk(titolo.getDescrizione(),
                                    FontFactory.getFont("ARIAL_BOLD", 12));
                            // Imposta il testo completo nella cella
                            Phrase titoloPhrase = new Phrase();
                            // Aggiunta delle due parti alla cella
                            titoloPhrase.add(parte1);
                            titoloPhrase.add(parte2);
                            cellaTitolo.setPhrase(titoloPhrase);
                            cellaTitolo.setVerticalAlignment(Element.ALIGN_CENTER);
                            cellaTitolo.setHorizontalAlignment(Element.ALIGN_CENTER);
                            cellaTitolo.setPaddingBottom(5);
                            tableTitolo.setSpacingAfter(10f);
                            tableTitolo.addCell(cellaTitolo);
                            tableTitolo.setWidthPercentage(50);
                            document.add(tableTitolo);
                        }
                        k++;
                        if (k != 1) {
                            // Aggiungi un paragrafo vuoto
                            Paragraph emptyParagraph = new Paragraph("\n");
                            // emptyParagraph.setSpacingAfter(30f);
                            document.add(emptyParagraph);
                        }
                        // Crea un paragrafo per visualizzare le informazioni sull'oggetto
                        Paragraph oggettoParagraph = new Paragraph();
                        oggettoParagraph.setAlignment(Element.ALIGN_LEFT);
                        Font font = FontFactory.getFont("ARIAL", 13);
                        oggettoParagraph.add(new Phrase("Oggetto: " + oggetto.getNome(), font));
                        oggettoParagraph.setSpacingAfter(10f);
                        // Aggiunge le informazioni sull'oggetto al documento
                        document.add(oggettoParagraph);

                        int j = 0;
                        // Itera attraverso le misure
                        for (Provvedimento provvedimento : provvedimentiSorted) {
                            // Crea una tabella per visualizzare i dettagli della misura
                            PdfPTable provvedimentoTable = new PdfPTable(12);
                            currentPosition = writer.getVerticalPosition(false);
                            if (currentPosition < 90) {
                                document.newPage();
                            }

                            // Visualizza gli header solo nella prima iterazione
                            if (j == 0) {
                                PdfPCell rischioCell = createCell("Rischio ", 1, FontFactory.getFont("ARIAL", 10));
                                rischioCell.setBorderWidth(1f);
                                rischioCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                rischioCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(rischioCell);

                                PdfPCell stimaCell = createCell("Stima\n(PxD=R) ", 1,
                                        FontFactory.getFont("ARIAL", 10));
                                stimaCell.setBorderWidth(1f);
                                stimaCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                stimaCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(stimaCell);

                                PdfPCell misureCell = createCell("Misure di prevenzione e protezione ", 7,
                                        FontFactory.getFont("ARIAL", 10));
                                misureCell.setBorderWidth(1f);
                                misureCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                misureCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(misureCell);

                                PdfPCell mansioniCell = createCell("Mansioni esposte ", 2,
                                        FontFactory.getFont("ARIAL", 10));
                                mansioniCell.setBorderWidth(1f);
                                mansioniCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                mansioniCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(mansioniCell);

                                PdfPCell scadenzeCell = createCell("Termine\n(aa-mm-gg) ", 1,
                                        FontFactory.getFont("ARIAL", 10));
                                scadenzeCell.setBorderWidth(1f);
                                scadenzeCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                scadenzeCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(scadenzeCell);
                            }
                            j++;

                            // Imposta le proprietà della tabella
                            provvedimentoTable.setWidthPercentage(100);

                            // Popola la tabella con i dettagli della misura
                            PdfPCell rischioCell = createCell(replaceInvalidCharacters(provvedimento.getRischio()), 1,
                                    FontFactory.getFont("ARIAL", 9));
                            rischioCell.setBorderWidth(0);
                            rischioCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(rischioCell);
                            String stima = (provvedimento.getStimaP() + " x " + provvedimento.getStimaD() + " = "
                                    + provvedimento.getStimaR());
                            PdfPCell stimaCell = createCell(stima, 1, FontFactory.getFont("ARIAL", 10));
                            stimaCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                            stimaCell.setBorderWidth(0);
                            stimaCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(stimaCell);
                            PdfPCell misureCell = createCell(
                                    replaceInvalidCharacters(provvedimento.getNome().replace("\n", ""))
                                            .replace("\r", "").replace("€", " euro"),
                                    7,
                                    FontFactory.getFont("ARIAL", 10));
                            misureCell.setBorderWidth(0);
                            misureCell.setPaddingBottom(5);
                            misureCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(misureCell);
                            String soggettiEsposti = provvedimento.getSoggettiEsposti();
                            PdfPCell soggettiEspostiCell = createCell(soggettiEsposti, 2,
                                    FontFactory.getFont("ARIAL", 10));
                            soggettiEspostiCell.setBorderWidth(0);
                            soggettiEspostiCell.setCellEvent(new DottedBottomBorder());
                            if (soggettiEsposti != null) {
                                soggettiEsposti = replaceInvalidCharacters(soggettiEsposti).replace("&lt;", "<")
                                        .replace("&gt;", ">");
                            }
                            provvedimentoTable
                                    .addCell(soggettiEspostiCell);
                            String termine = provvedimento.getDataScadenza().toString();
                            if (termine == "Optional.empty") {
                                termine = "";
                            }
                            // Trova l'indice delle parentesi quadre
                            int startIndex = termine.indexOf("[");
                            int endIndex = termine.indexOf("]");
                            // Se entrambi gli indici sono validi, estrai la data
                            if (startIndex != -1 && endIndex != -1) {
                                termine = termine.substring(startIndex + 1, endIndex);
                            }
                            PdfPCell termineCell = createCell(termine, 1,
                                    FontFactory.getFont("ARIAL", 10));
                            termineCell.setBorderWidth(0);
                            termineCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable
                                    .addCell(termineCell);
                            // Aggiunge la tabella delle misure al documento
                            document.add(provvedimentoTable);
                        }
                    }
                }
            }
        } catch (DocumentException | IOException e) {
            // Gestisce le eccezioni legate al documento
            e.printStackTrace();
        } finally {
            // Chiude il documento se è aperto
            if (document != null && document.isOpen()) {
                document.close();
            }
            pagineTotali = paginaAttuale;
            paginaAttuale = 0;
            System.out.println();
            stampaValutazioneRischiRender(societa, unitaLocale, reparti, nomeFile);
        }

    }

    // METODO CHE FA LA STAMPA FINALE
    public static void stampaValutazioneRischiRender(Societa societa, UnitaLocale unitaLocale, List<Reparto> reparti,
            String nomeFile) {
        // Formatta la data
        SimpleDateFormat formatoIngresso = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat formatoUscita = new SimpleDateFormat("dd/MM/yyyy");
        // Crea un nuovo documento con una dimensione personalizzata
        Document document = new Document(PageSize.A4.rotate(), 36, 36, 50, 36);
        paginaAttuale = 0;
        revisione = reparti.get(0).getRevisione();
        try {
            // Crea un'istanza di PdfWriter e imposta un piè di pagina personalizzato per il
            // documento
            PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(nomeFile));
            writer.setPageEvent(new PdfFooter());
            // Apre il documento
            document.open();
            // Creazione pagina iniziale
            PdfPTable tableIniziale = new PdfPTable(8);
            tableIniziale.setWidthPercentage(100);
            PdfPCell societaCellIniziale = createCell("Società/Ente: ", 1,
                    FontFactory.getFont("ARIAL", 10));
            tableIniziale.addCell(societaCellIniziale);
            PdfPCell nomeSocietaCellIniziale = createCell(societa.getNome(), 3,
                    FontFactory.getFont("ARIAL_BOLD", 10));
            tableIniziale.addCell(nomeSocietaCellIniziale);
            PdfPCell unitaLocaleCellIniziale = createCell("Un. Produttiva: ", 1,
                    FontFactory.getFont("ARIAL", 10));
            tableIniziale.addCell(unitaLocaleCellIniziale);
            PdfPCell nomeUnitaLocaleCellIniziale = createCell(unitaLocale.getNome(), 3,
                    FontFactory.getFont("ARIAL_BOLD", 10));
            tableIniziale.addCell(nomeUnitaLocaleCellIniziale);
            tableIniziale.setSpacingAfter(60f);
            // Aggiunge la tabella iniziale al documento e vado alla seconda pagina
            document.add(tableIniziale);

            // LOGO CHECKUPS
            PdfPTable tableLogoChekups = new PdfPTable(1);
            tableLogoChekups.setWidthPercentage(100);
            Image logoCheckUpsImage = Image.getInstance(urlLogoCheckUps);
            if (societa.hasImage()) {
                logoCheckUpsImage = javafxImageToPdfImage(societa.getLogoImage());
            }
            // Imposta le dimensioni dell'immagine
            PdfPCell logoChekups = createImageCell(logoCheckUpsImage, 1);
            logoChekups.setHorizontalAlignment(Element.ALIGN_CENTER);
            logoChekups.setVerticalAlignment(Element.ALIGN_MIDDLE);
            logoChekups.setBorder(Rectangle.NO_BORDER);
            logoChekups.setFixedHeight(63f);
            tableLogoChekups.addCell(logoChekups);
            tableLogoChekups.setSpacingAfter(60f);
            document.add(tableLogoChekups);
            logoCheckUpsImage = Image.getInstance(urlLogoCheckUps);
            // SCRITTE SOTTO LOGO
            // Crea la tabella
            PdfPTable tableBody = new PdfPTable(1);
            tableBody.setWidthPercentage(100);

            // Crea il font principale (16 punti)
            Font fontGrande = FontFactory.getFont("ARIAL", 16);
            // Crea il font per la parte più piccola (14 punti, 2 punti in meno)
            Font fontPiccolo = FontFactory.getFont("ARIAL", 14);

            // Crea il testo con due parti: una con il font grande e una con il font piccolo
            Phrase phrase = new Phrase();
            phrase.add(new Chunk(
                    "Relazione Tecnica di Valutazione Rischi - \n in materia di salute e sicurezza sul lavoro D.Lgs. n. 81/2008 e s.m. e i. \n \n \n",
                    fontGrande));
            phrase.add(new Chunk("Firmano in data: ________________________ ", fontPiccolo));

            // Crea la cella e aggiungi il Phrase
            PdfPCell body = new PdfPCell(phrase);
            body.setHorizontalAlignment(Element.ALIGN_CENTER);
            body.setVerticalAlignment(Element.ALIGN_MIDDLE);
            body.setBorder(Rectangle.NO_BORDER);

            // Aggiungi la cella alla tabella
            tableBody.addCell(body);
            tableBody.setSpacingAfter(35f);

            // Aggiungi la tabella al documento
            document.add(tableBody);
            // Tabella contenente le firme
            PdfPTable tableUnderBody = new PdfPTable(2);
            PdfPCell underBodyLeft = createCell(
                    "Il Datore di Lavoro \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            PdfPCell underBodyRight = createCell(
                    "Il Rappresentante dei lavoratori per la sicurezza (RLS) \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyLeft.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyLeft.setVerticalAlignment(Element.ALIGN_MIDDLE);
            underBodyRight.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyRight.setVerticalAlignment(Element.ALIGN_MIDDLE);
            tableUnderBody.addCell(underBodyLeft);
            tableUnderBody.addCell(underBodyRight);
            tableUnderBody.setWidthPercentage(65);
            underBodyLeft = createCell(
                    "Il Responsabile del servizio di Prevenzione e Protezione \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyRight = createCell(
                    "Il Medico Competente \n \n \n \n \n \n",
                    1, FontFactory.getFont("ARIAL_ITALIC", 10));
            underBodyLeft.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyLeft.setVerticalAlignment(Element.ALIGN_MIDDLE);
            underBodyRight.setHorizontalAlignment(Element.ALIGN_CENTER);
            underBodyRight.setVerticalAlignment(Element.ALIGN_MIDDLE);
            tableUnderBody.addCell(underBodyLeft);
            tableUnderBody.addCell(underBodyRight);
            tableUnderBody.setSpacingAfter(40f);
            document.add(tableUnderBody);

            if (societa.hasImage()) {
                logoSocieta = javafxImageToPdfImage(societa.getLogoImage());
            }
            document.newPage();
            // Aggiungo l'indice
            aggiungiIndiceContenuti(document);
            document.newPage();
            int i = 0;
            // Itera attraverso i reparti per la valutazione dei rischi
            for (Reparto reparto : reparti) {
                writer.setPageEvent(new IntestazioneEvent(societa, unitaLocale, reparto));
                revisione = reparto.getRevisione();
                if (i != 0) {
                    document.newPage();
                }
                i++;
                if (reparto.getData().isPresent()) {
                    try {
                        // Parsing della data in arrivo
                        Date dataParsed = formatoIngresso.parse(reparto.getData().get().toString());
                        // Formattazione della data nel nuovo formato
                        dataValutazione = formatoUscita.format(dataParsed);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                } else {
                    try {
                        // Parsing della data in arrivo
                        Date dataParsed = formatoIngresso.parse("1900-01-01");
                        // Formattazione della data nel nuovo formato
                        dataValutazione = formatoUscita.format(dataParsed);
                    } catch (ParseException e) {
                        e.printStackTrace();
                    }
                }
                // Filtra i titoli in base al reparto
                List<Titolo> titoli = ModelListe.filtraTitoliDaReparto(Collections.singletonList(reparto));
                // Ordino i titoli
                List<Titolo> titoliSorted = new ArrayList<>(titoli);
                Collections.sort(titoliSorted, (t1, t2) -> Integer.compare(t1.getPriorita(), t2.getPriorita()));

                // Itera attraverso i titoli
                for (Titolo titolo : titoliSorted) {
                    // All'inizio del ciclo per gli oggetti e i titoli, registra la posizione
                    // corrente nella pagina
                    float currentPosition = writer.getVerticalPosition(false);
                    currentPosition = writer.getVerticalPosition(false);
                    if (currentPosition < 430) {
                        document.newPage();
                    }
                    // Filtra gli oggetti in base al titolo
                    List<Oggetto> oggetti = ModelListe.filtraOggettiDaTitolo(titolo.getId());
                    // Ordino gli oggetti
                    List<Oggetto> oggettiSorted = new ArrayList<>(oggetti);
                    Collections.sort(oggettiSorted, (o1, o2) -> Integer.compare(o1.getPriorita(), o2.getPriorita()));
                    document.add(Chunk.NEWLINE);

                    int k = 0;
                    // Itera attraverso gli oggetti
                    for (Oggetto oggetto : oggettiSorted) {
                        currentPosition = writer.getVerticalPosition(false);
                        if (currentPosition < 150 && oggettiSorted.size() != k) {
                            document.newPage();
                        }
                        // Filtra le misure in base all'oggetto
                        List<Provvedimento> provvedimenti = ModelListe.filtraProvvedimentiDaOggetto(oggetto.getId());
                        // Ordino i provvedimenti
                        List<Provvedimento> provvedimentiSorted = new ArrayList<>(provvedimenti);
                        Collections.sort(provvedimentiSorted,
                                (p1, p2) -> Integer.compare(p1.getPriorita(), p2.getPriorita()));
                        // Salta se non ci sono misure per l'oggetto
                        if (provvedimentiSorted.size() == 0) {
                            continue;
                        }
                        // Controlla se è la prima iterazione per evitare interruzioni di pagina non
                        // necessarie
                        if (k == 0) {
                            // Titolo
                            PdfPTable tableTitolo = new PdfPTable(1);
                            // Creazione della cella per il titolo
                            PdfPCell cellaTitolo = new PdfPCell();
                            // Creazione del testo per la prima parte (Arial Bold)
                            Chunk parte1 = new Chunk("Titolo: ", FontFactory.getFont("ARIAL", 12));
                            // Creazione del testo per la seconda parte (Arial)
                            Chunk parte2 = new Chunk(titolo.getDescrizione(),
                                    FontFactory.getFont("ARIAL_BOLD", 12));
                            // Imposta il testo completo nella cella
                            Phrase titoloPhrase = new Phrase();
                            // Aggiunta delle due parti alla cella
                            titoloPhrase.add(parte1);
                            titoloPhrase.add(parte2);
                            cellaTitolo.setPhrase(titoloPhrase);
                            cellaTitolo.setVerticalAlignment(Element.ALIGN_CENTER);
                            cellaTitolo.setHorizontalAlignment(Element.ALIGN_CENTER);
                            cellaTitolo.setPaddingBottom(5);
                            tableTitolo.setSpacingAfter(10f);
                            tableTitolo.addCell(cellaTitolo);
                            tableTitolo.setWidthPercentage(50);
                            document.add(tableTitolo);
                        }
                        k++;
                        if (k != 1) {
                            // Aggiungi un paragrafo vuoto
                            Paragraph emptyParagraph = new Paragraph("\n");
                            // emptyParagraph.setSpacingAfter(30f);
                            document.add(emptyParagraph);
                        }
                        // Crea un paragrafo per visualizzare le informazioni sull'oggetto
                        Paragraph oggettoParagraph = new Paragraph();
                        oggettoParagraph.setAlignment(Element.ALIGN_LEFT);
                        Font font = FontFactory.getFont("ARIAL", 13);
                        oggettoParagraph.add(new Phrase("Oggetto: " + oggetto.getNome(), font));
                        oggettoParagraph.setSpacingAfter(10f);
                        // Aggiunge le informazioni sull'oggetto al documento
                        document.add(oggettoParagraph);

                        int j = 0;
                        // Itera attraverso le misure
                        for (Provvedimento provvedimento : provvedimentiSorted) {
                            // Crea una tabella per visualizzare i dettagli della misura
                            PdfPTable provvedimentoTable = new PdfPTable(12);
                            currentPosition = writer.getVerticalPosition(false);
                            if (currentPosition < 90) {
                                document.newPage();
                            }
                            // Visualizza gli header solo nella prima iterazione
                            if (j == 0) {
                                PdfPCell rischioCell = createCell("Rischio ", 1, FontFactory.getFont("ARIAL", 10));
                                rischioCell.setBorderWidth(1f);
                                rischioCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                rischioCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(rischioCell);

                                PdfPCell stimaCell = createCell("Stima\n(PxD=R) ", 1,
                                        FontFactory.getFont("ARIAL", 10));
                                stimaCell.setBorderWidth(1f);
                                stimaCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                stimaCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(stimaCell);

                                PdfPCell misureCell = createCell("Misure di prevenzione e protezione ", 7,
                                        FontFactory.getFont("ARIAL", 10));
                                misureCell.setBorderWidth(1f);
                                misureCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                misureCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(misureCell);

                                PdfPCell mansioniCell = createCell("Mansioni esposte ", 2,
                                        FontFactory.getFont("ARIAL", 10));
                                mansioniCell.setBorderWidth(1f);
                                mansioniCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                mansioniCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(mansioniCell);

                                PdfPCell scadenzeCell = createCell("Termine\n(aa-mm-gg) ", 1,
                                        FontFactory.getFont("ARIAL", 10));
                                scadenzeCell.setBorderWidth(1f);
                                scadenzeCell.setVerticalAlignment(Element.ALIGN_CENTER);
                                scadenzeCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                                provvedimentoTable.addCell(scadenzeCell);

                            }
                            j++;

                            // Imposta le proprietà della tabella
                            provvedimentoTable.setWidthPercentage(100);

                            // Popola la tabella con i dettagli della misura
                            PdfPCell rischioCell = createCell(replaceInvalidCharacters(provvedimento.getRischio()), 1,
                                    FontFactory.getFont("ARIAL", 9));
                            rischioCell.setBorderWidth(0);
                            rischioCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(rischioCell);
                            String stima = (provvedimento.getStimaP() + " x " + provvedimento.getStimaD() + " = "
                                    + provvedimento.getStimaR());
                            PdfPCell stimaCell = createCell(stima, 1, FontFactory.getFont("ARIAL", 10));
                            stimaCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                            stimaCell.setBorderWidth(0);
                            stimaCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(stimaCell);
                            PdfPCell misureCell = createCell(
                                    replaceInvalidCharacters(provvedimento.getNome().replace("\n", ""))
                                            .replace("\r", "").replace("€", " euro"),
                                    7,
                                    FontFactory.getFont("ARIAL", 10));
                            misureCell.setBorderWidth(0);
                            misureCell.setPaddingBottom(5);
                            misureCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable.addCell(misureCell);
                            String soggettiEsposti = provvedimento.getSoggettiEsposti();
                            PdfPCell soggettiEspostiCell = createCell(soggettiEsposti, 2,
                                    FontFactory.getFont("ARIAL", 10));
                            soggettiEspostiCell.setBorderWidth(0);
                            soggettiEspostiCell.setCellEvent(new DottedBottomBorder());
                            if (soggettiEsposti != null) {
                                soggettiEsposti = replaceInvalidCharacters(soggettiEsposti).replace("&lt;", "<")
                                        .replace("&gt;", ">");
                            }
                            provvedimentoTable
                                    .addCell(soggettiEspostiCell);
                            String termine = provvedimento.getDataScadenza().toString();
                            if (termine == "Optional.empty") {
                                termine = "";
                            }
                            // Trova l'indice delle parentesi quadre
                            int startIndex = termine.indexOf("[");
                            int endIndex = termine.indexOf("]");
                            // Se entrambi gli indici sono validi, estrai la data
                            if (startIndex != -1 && endIndex != -1) {
                                termine = termine.substring(startIndex + 1, endIndex);
                            }
                            PdfPCell termineCell = createCell(termine, 1,
                                    FontFactory.getFont("ARIAL", 10));
                            termineCell.setBorderWidth(0);
                            termineCell.setCellEvent(new DottedBottomBorder());
                            provvedimentoTable
                                    .addCell(termineCell);
                            // Aggiunge la tabella delle misure al documento
                            document.add(provvedimentoTable);
                        }
                    }
                }
            }
        } catch (DocumentException | IOException e) {
            // Gestisce le eccezioni legate al documento
            e.printStackTrace();
        } finally {
            // Chiude il documento se è aperto
            if (document != null && document.isOpen()) {
                document.close();
            }
            paginaAttuale = 0;
            pagineTotali = 0;
        }
    }

    // Metodo di supporto per creare una PdfPCell con contenuto, colspan e stile del
    // carattere specificati
    private static PdfPCell createCell(String content, int colspan, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(content, font));
        cell.setColspan(colspan);
        return cell;
    }

    private static PdfPCell createImageCell(Image image, int colspan) {
        PdfPCell cell = new PdfPCell(image, true);
        cell.setColspan(colspan);
        return cell;
    }

    // Metodo per convertire un'immagine JavaFX in un'immagine iTextPDF
    private static Image javafxImageToPdfImage(javafx.scene.image.Image javafxImage) {
        // Converti l'immagine JavaFX in un'immagine AWT
        BufferedImage awtImage = SwingFXUtils.fromFXImage(javafxImage, null);

        // Converti l'immagine AWT in un'immagine iTextPDF
        Image pdfImage = null;
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(awtImage, "png", baos);
            baos.flush();
            byte[] imageInByte = baos.toByteArray();
            baos.close();
            pdfImage = Image.getInstance(imageInByte);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return pdfImage;
    }

    // Classe interna per definire un piè di pagina personalizzato per il documento
    // PDF
    private static class PdfFooter extends PdfPageEventHelper {
        public void onStartPage(PdfWriter writer, Document document) {
            // Crea una tabella per il piè di pagina con tre colonne
            PdfPTable table = new PdfPTable(3);
            paginaAttuale++;
            // Imposta il colore del bordo delle celle su bianco
            table.getDefaultCell().setBorderColor(BaseColor.WHITE);
            table.setTotalWidth(document.right() - document.left());
            table.getDefaultCell().setFixedHeight(41);
            table.getDefaultCell().setHorizontalAlignment(Element.ALIGN_CENTER);

            // Aggiunge data, logo e numero di pagina al piè di pagina
            Phrase phrase = new Phrase();
            phrase.add(new Chunk("Redatto a cura di: ", FontFactory.getFont(FontFactory.HELVETICA, 10))); // Aggiunge il
                                                                                                          // testo
            try {
                Image logo = Image.getInstance(urlLogoCheckUps);
                logo.scaleToFit(70, 70); // imposta larghezza e altezza massima
                // Inserisci il logo nel Chunk con un offset verticale (es. -40 pixel)
                Chunk logoChunk = new Chunk(logo, 0,-22);
                phrase.add(logoChunk);
            } catch (Exception e) {
                System.out.println("Errore nel caricamento del logo piccolo al piè di pagina");
            }
            
            PdfPCell cellLogoCheckUps = new PdfPCell(phrase);
            cellLogoCheckUps.setBorderColor(BaseColor.WHITE);
            cellLogoCheckUps.setVerticalAlignment(Element.ALIGN_CENTER);
            cellLogoCheckUps.setPaddingBottom(10f);
            table.addCell(cellLogoCheckUps);
            if (logoSocieta != null) {
                // CLONA l'immagine (importantissimo: Image è mutabile!)
                Image footerLogo = Image.getInstance(logoSocieta);

                // scala per stare dentro al footer (altezza reale ~ 30)
                footerLogo.scaleToFit(80, 40); // <-- cambia qui se vuoi più grande/piccolo

                PdfPCell logoCell = new PdfPCell(footerLogo, false);
                logoCell.setBorder(Rectangle.NO_BORDER);
                logoCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                logoCell.setVerticalAlignment(Element.ALIGN_MIDDLE);

                // niente padding "strani": sono loro che fanno l'effetto gigante
                logoCell.setPadding(0f);

                table.addCell(logoCell);
            } else {
                table.addCell("");
            }

            PdfPCell cellPagineRev = new PdfPCell(new Phrase("Rev N. " + revisione + " del: " + dataValutazione
                    + " - Pag. " + (paginaAttuale) + " di " + (pagineTotali),
                    FontFactory.getFont(FontFactory.HELVETICA, 10)));
            cellPagineRev.setVerticalAlignment(Element.ALIGN_BOTTOM); // Imposta l'allineamento verticale in basso
            cellPagineRev.setBorderColor(BaseColor.WHITE);
            cellPagineRev.setVerticalAlignment(Element.ALIGN_CENTER);
            cellPagineRev.setHorizontalAlignment(Element.ALIGN_RIGHT);
            cellPagineRev.setPaddingBottom(10f);
            table.addCell(cellPagineRev);
            // Scrive il piè di pagina nel documento
            table.writeSelectedRows(0, -1, document.left(), document.bottom() + 5, writer.getDirectContent());
        }
    }

    // Classe per il bordo inferiore tratteggiato
    private static class DottedBottomBorder implements PdfPCellEvent {
        @Override
        public void cellLayout(PdfPCell cell, Rectangle position, PdfContentByte[] canvases) {
            PdfContentByte canvas = canvases[PdfPTable.LINECANVAS];
            canvas.saveState();
            canvas.setLineDash(3, 3);
            canvas.setLineWidth(1f);
            canvas.setColorStroke(BaseColor.LIGHT_GRAY);
            canvas.moveTo(position.getLeft(), position.getBottom());
            canvas.lineTo(position.getRight(), position.getBottom());
            canvas.stroke();
            canvas.restoreState();
        }
    }

    // Metodo di supporto per sostituire caratteri non validi in un testo
    private static String replaceInvalidCharacters(String text) {
        // Sostituisci caratteri non validi con un punto interrogativo
        text = text.replaceAll("&apos;", "' ");
        // Aggiungi ulteriori operazioni di sostituzione se necessario
        return text;
    }
    private static void aggiungiIndiceContenuti(Document document) throws DocumentException {
        PdfPTable tableIndice = new PdfPTable(1);
            // Add cells to the table
            PdfPCell cella = createCell(
                    "INDICE dei contenuti ex D.Lgs. 81/08",
                    1, FontFactory.getFont("ARIAL", 12));
            cella.setHorizontalAlignment(Element.ALIGN_CENTER);
            cella.setBorder(0);

            tableIndice.addCell(cella);
            document.add(tableIndice);

            // Creazione del testo dell'indice su due colonne
            PdfPTable indice = new PdfPTable(3);
            indice.setWidthPercentage(100);
            indice.getDefaultCell().setBorder(Rectangle.NO_BORDER);
            indice.setWidths(new float[] { 1f, 1.6f, 1.4f });

            // Crea il font con dimensione 10
            Font smallFont = FontFactory.getFont("ARIAL", 9);
            // Prima colonna
            PdfPCell col1 = new PdfPCell();
            col1.setBorder(Rectangle.NO_BORDER);
            col1.addElement(new Paragraph("\n\n1.    Titolo I – Gestione della prevenzione\n", smallFont));
            col1.addElement(new Paragraph("      a. Servizio di Prevenzione e Protezione\n", smallFont));
            col1.addElement(new Paragraph("      b. Formazione, addestramento\n", smallFont));
            col1.addElement(new Paragraph("      c. Procedure di sicurezza\n", smallFont));
            col1.addElement(new Paragraph("      d. Prevenzione incendi\n", smallFont));
            col1.addElement(new Paragraph("      e. Gestione Emergenze\n", smallFont));
            col1.addElement(new Paragraph("      f. Primo Soccorso\n", smallFont));
            col1.addElement(new Paragraph("      g. Sorveglianza Sanitaria\n", smallFont));
            col1.addElement(new Paragraph("      h. Rischi psico sociali\n", smallFont));
            col1.addElement(new Paragraph("      i. Lavori in appalto interni\n", smallFont));
            col1.addElement(new Paragraph("      j. Tutela della maternità\n", smallFont));

            col1.addElement(new Paragraph("\n2.    Titolo II - Luoghi di lavoro\n", smallFont));
            col1.addElement(new Paragraph("      a. Locali di lavoro\n", smallFont));
            col1.addElement(new Paragraph("      b. Igiene del lavoro; microclima\n", smallFont));
            col1.addElement(new Paragraph("      c. Lavori in quota\n", smallFont));
            col1.addElement(new Paragraph("      d. Soppalchi\n", smallFont));
            col1.addElement(new Paragraph("      e. Ambienti confinati\n", smallFont));
            col1.addElement(new Paragraph("      f. Vie di Circolazione\n", smallFont));
            col1.addElement(new Paragraph("      g. Servizi igienico assitenziali\n", smallFont));
            col1.addElement(new Paragraph("      h. Assistenza esterna\n", smallFont));
            col1.addElement(new Paragraph("      g. Smart working\n", smallFont));

            // Seconda colonna
            PdfPCell col2 = new PdfPCell();
            col2.setBorder(Rectangle.NO_BORDER);
            col2.addElement(new Paragraph("\n\n3.    Titolo III – Uso di Impianti, Macchine e Attrezzature di lavoro\n",
                    smallFont));
            col2.addElement(new Paragraph("      a. Organizzazione del lavoro\n", smallFont));
            col2.addElement(new Paragraph("      b. Macchine e attrezzature\n", smallFont));
            col2.addElement(new Paragraph("      c. Apparecchi portatili\n", smallFont));
            col2.addElement(new Paragraph("      d. Utensili manuali\n", smallFont));
            col2.addElement(new Paragraph("      e. Mezzi di sollevamento materiali\n", smallFont));
            col2.addElement(new Paragraph("      f. Carrelli elevatori\n", smallFont));
            col2.addElement(new Paragraph("      g. Scaffalature metalliche\n", smallFont));
            col2.addElement(new Paragraph("      h. Trabattelli\n", smallFont));
            col2.addElement(new Paragraph("      i. Cancelli e serrande elettrici\n", smallFont));
            col2.addElement(new Paragraph("      j. Mezzi di trasporto persone\n", smallFont));
            col2.addElement(new Paragraph("      k. Impianti elettrici; scariche atmosferiche\n", smallFont));
            col2.addElement(new Paragraph("      l. Impianti termici\n", smallFont));
            col2.addElement(new Paragraph("      m. Ascensori, montacarichi pedane\n", smallFont));
            col2.addElement(new Paragraph("      n. Apparecchi in pressione\n", smallFont));

            col2.addElement(new Paragraph("\n3.1   Uso dei Dispositivi di Protezione Individuale\n", smallFont));

            col2.addElement(new Paragraph("\n4.    Titolo IV – Cantieri temporanei e mobili\n", smallFont));
            col2.addElement(new Paragraph("      a. Misure generali di salute e sicurezza\n", smallFont));
            col2.addElement(new Paragraph("      b. Viabilità e recinzione\n", smallFont));
            col2.addElement(new Paragraph("      c. Opere provvisionali\n", smallFont));
            col2.addElement(new Paragraph("      d. Scavi e fondazioni\n", smallFont));
            col2.addElement(new Paragraph("      e. Costruzioni edilizie\n", smallFont));
            col2.addElement(new Paragraph("      f. Demolizioni\n", smallFont));

            // Terza colonna
            PdfPCell col3 = new PdfPCell();
            col3.setBorder(Rectangle.NO_BORDER);
            col3.addElement(
                    new Paragraph("\n\n5.    Titolo V – Segnaletica di salute e sicurezza sul lavoro\n", smallFont));
            col3.addElement(new Paragraph("      a. Segnali di Sicurezza\n", smallFont));
            col3.addElement(new Paragraph("      b. Segnali di emergenza\n", smallFont));

            col3.addElement(new Paragraph("\n6.    Titolo VI – Movimentazione manuale dei carichi\n", smallFont));
            col3.addElement(new Paragraph("      a. Movimentazione manuale dei carichi\n", smallFont));
            col3.addElement(new Paragraph("      b. Movimenti ripetitivi\n", smallFont));
            col3.addElement(new Paragraph("      c. Rischi ergonomici\n", smallFont));

            col3.addElement(new Paragraph("\n7.    Titolo VII – Attrezzature munite di Videoterminali\n", smallFont));

            col3.addElement(new Paragraph("\n8.    Titolo VIII – Agenti fisici\n", smallFont));
            col3.addElement(new Paragraph("      a. Rumore\n", smallFont));
            col3.addElement(new Paragraph("      b. Vibrazioni meccaniche\n", smallFont));
            col3.addElement(new Paragraph("      c. Campi elettromagnetici\n", smallFont));
            col3.addElement(new Paragraph("      d. Radiazioni ottiche artificiali\n", smallFont));
            col3.addElement(new Paragraph("      e. Radiazioni ionizzanti\n", smallFont));

            col3.addElement(new Paragraph("\n9.   Titolo IX – Sostanze pericolose\n", smallFont));
            col3.addElement(new Paragraph("      a. Rischio chimico\n", smallFont));
            col3.addElement(new Paragraph("      b. Rischi cancerogeni o mutageni\n", smallFont));
            col3.addElement(new Paragraph("      c. Materiali con Amianto\n", smallFont));

            col3.addElement(new Paragraph("\n10.   Titolo X – Esposizione ad agenti Biologici\n", smallFont));

            col3.addElement(new Paragraph("\n11.   Titolo XI – Protezione da Atmosfere esplosive\n", smallFont));

            indice.addCell(col1);
            indice.addCell(col2);
            indice.addCell(col3);
            document.add(indice);
    }
    public static class IntestazioneEvent extends PdfPageEventHelper {
    private final Societa societa;
    private final UnitaLocale unitaLocale;
    private final Reparto reparto;
    private final Font labelFont = FontFactory.getFont("ARIAL", 8);
    private final Font valueFont = FontFactory.getFont("ARIAL_BOLD", 9);


    public IntestazioneEvent(Societa societa, UnitaLocale unitaLocale, Reparto reparto) {
        this.societa = societa;
        this.unitaLocale = unitaLocale;
        this.reparto = reparto;
    }
    

    @Override
        public void onEndPage(PdfWriter writer, Document document) {
            int currentPage = writer.getPageNumber();
            if (currentPage == 1) return; // Salta la prima pagina

            try {
                PdfPTable table = creaTabellaIntestazione(societa, unitaLocale, reparto, labelFont, valueFont);
                table.setWidthPercentage(100);

                ColumnText ct = new ColumnText(writer.getDirectContent());

                // Imposta i margini dell'area in cui verrà disegnata la tabella
                float left = document.left();
                float right = document.right();
                float top = document.getPageSize().getHeight() - 25;
                float bottom = document.bottom(); 

                ct.setSimpleColumn(left, bottom, right, top); // area dove disegnare
                ct.addElement(table);
                ct.go();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    

    public static PdfPTable creaTabellaIntestazione(Societa societa, UnitaLocale unitaLocale, Reparto reparto,
                                                    Font labelFont, Font valueFont) {
        PdfPTable table = new PdfPTable(21);
        table.setWidthPercentage(100);

        PdfPCell societaCell = createCell("Società:", 1, labelFont);
        societaCell.setBorder(Rectangle.NO_BORDER);
        table.addCell(societaCell);

        societaCell = createCell(societa.getNome(), 5, valueFont);
        societaCell.setBorderWidthTop(0);
        societaCell.setBorderWidthLeft(0);
        societaCell.setBorderWidthRight(0);
        table.addCell(societaCell);

        PdfPCell unitaLocaleCell = createCell("    Un. Produttiva:", 2, labelFont);
        unitaLocaleCell.setBorder(Rectangle.NO_BORDER);
        table.addCell(unitaLocaleCell);

        unitaLocaleCell = createCell(unitaLocale.getNome(), 6, valueFont);
        unitaLocaleCell.setBorderWidthTop(0);
        unitaLocaleCell.setBorderWidthLeft(0);
        unitaLocaleCell.setBorderWidthRight(0);
        table.addCell(unitaLocaleCell);

        PdfPCell repartiCell = createCell("    Reparto:", 2, labelFont);
        repartiCell.setBorder(Rectangle.NO_BORDER);
        table.addCell(repartiCell);

        repartiCell = createCell(reparto.getNome(), 5, valueFont);
        repartiCell.setBorderWidthTop(0);
        repartiCell.setBorderWidthLeft(0);
        repartiCell.setBorderWidthRight(0);
        table.addCell(repartiCell);
         // Riga vuota per spazio extra
        PdfPCell emptySpaceCell = new PdfPCell(new Phrase(" "));
        emptySpaceCell.setColspan(21);
        emptySpaceCell.setBorder(Rectangle.NO_BORDER);
        emptySpaceCell.setFixedHeight(20f); // ad esempio 20 punti
        table.addCell(emptySpaceCell);

        return table;
    }

    private static PdfPCell createCell(String content, int colspan, Font font) {
        PdfPCell cell = new PdfPCell(new Phrase(content, font));
        cell.setColspan(colspan);
        cell.setPadding(3);
        return cell;
    }
    }
}
