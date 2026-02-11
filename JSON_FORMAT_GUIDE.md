# JSON Format Guide - Hadithi kwa Watoto

Complete guide for importing stories and data into the app using JSON format.

---

## 📋 Table of Contents

1. [Basic Story Format](#basic-story-format)
2. [Story with Chapters](#story-with-chapters)
3. [Story with Chapter Images](#story-with-chapter-images)
4. [Multiple Stories](#multiple-stories)
5. [Field Descriptions](#field-descriptions)
6. [Examples](#examples)
7. [Tips & Best Practices](#tips--best-practices)

---

## 1. Basic Story Format

For simple stories without chapters:

```json
[
  {
    "title": "Sungura Mwerevu",
    "author": "Hassan Mwinyi",
    "category": "Adventure",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../cover.jpg",
    "synopsis": "Hadithi ya sungura mwerevu aliyeokoa wanyama wote msituni.",
    "readingTimeMinutes": 5,
    "tags": ["adventure", "animals", "clever"],
    "isFeatured": false,
    "content": "Hapo zamani za kale, kulikuwa na sungura mwerevu...",
    "chapters": []
  }
]
```

---

## 2. Story with Chapters

For stories divided into chapters with verses:

```json
[
  {
    "title": "Safari ya Simba - Sehemu ya 1",
    "author": "Fatuma Ahmed",
    "category": "Adventure",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../simba-cover.jpg",
    "synopsis": "Simba mdogo anatafuta njia yake nyumbani kupitia msitu mkubwa.",
    "readingTimeMinutes": 15,
    "tags": ["adventure", "lion", "journey"],
    "isFeatured": true,
    "chapters": [
      {
        "number": 1,
        "title": "Sura ya Kwanza: Kupotea",
        "verses": [
          {
            "number": 1,
            "text": "Ilikuwa asubuhi ya mapema msituni. Simba mdogo aliamka akiwa peke yake."
          },
          {
            "number": 2,
            "text": "Alitazama kushoto na kulia, lakini hakuona mama yake wala familia yake."
          },
          {
            "number": 3,
            "text": "Moyo wake ulianza kupiga kwa kasi. 'Nina...nipotee?' alijuliza kwa sauti ya chini."
          }
        ]
      },
      {
        "number": 2,
        "title": "Sura ya Pili: Kukutana na Ndege",
        "verses": [
          {
            "number": 1,
            "text": "Simba alitembea kwa muda mrefu. Ghafla, alisikia sauti ya kuimba juu ya kichwa chake."
          },
          {
            "number": 2,
            "text": "'Habari yako, kijana!' ndege mdogo alisema kwa sauti ya furaha."
          },
          {
            "number": 3,
            "text": "'Nina...nimepotea,' Simba alijibu kwa huzuni. 'Je, unaweza kunisaidia?'"
          }
        ]
      }
    ]
  }
]
```

---

## 3. Story with Chapter Images

Add images to chapters for visual storytelling:

```json
[
  {
    "title": "Hadithi ya Mvua",
    "author": "John Kamau",
    "category": "Educational",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../rain-cover.jpg",
    "synopsis": "Jinsi mvua inavyotokea na umuhimu wake kwa maisha.",
    "readingTimeMinutes": 10,
    "tags": ["educational", "nature", "weather"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Sura ya Kwanza: Mawingu",
        "imageUrl": "https://firebasestorage.googleapis.com/.../clouds.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Angalia juu angani. Unaona mawingu meupe mazuri?"
          },
          {
            "number": 2,
            "text": "Mawingu hayo yanajaa maji kutoka baharini na mabwawani."
          }
        ]
      },
      {
        "number": 2,
        "title": "Sura ya Pili: Mvua Inanyesha",
        "imageUrl": "https://firebasestorage.googleapis.com/.../rain.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Mawingu yanapokuwa mazito sana, maji yanaanza kuanguka."
          },
          {
            "number": 2,
            "text": "Hii ndiyo mvua! Mvua ni muhimu kwa mimea, wanyama, na binadamu."
          }
        ]
      },
      {
        "number": 3,
        "title": "Sura ya Tatu: Baada ya Mvua",
        "imageUrl": "https://firebasestorage.googleapis.com/.../rainbow.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Baada ya mvua, unaweza kuona upinde wa mvua - rangi saba nzuri angani!"
          },
          {
            "number": 2,
            "text": "Mimea inakuwa kijani na majani mapya huchipua kila mahali."
          }
        ]
      }
    ]
  }
]
```

---

## 4. Multiple Stories

Import many stories at once:

```json
[
  {
    "title": "Hadithi ya Kwanza",
    "author": "Author 1",
    "category": "Adventure",
    "coverImageUrl": "https://example.com/cover1.jpg",
    "synopsis": "Hadithi ya kwanza...",
    "readingTimeMinutes": 5,
    "tags": ["tag1", "tag2"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Chapter 1",
        "verses": [
          {
            "number": 1,
            "text": "Mwanzo wa hadithi..."
          }
        ]
      }
    ]
  },
  {
    "title": "Hadithi ya Pili",
    "author": "Author 2",
    "category": "Educational",
    "coverImageUrl": "https://example.com/cover2.jpg",
    "synopsis": "Hadithi ya pili...",
    "readingTimeMinutes": 8,
    "tags": ["tag3", "tag4"],
    "isFeatured": true,
    "chapters": [
      {
        "number": 1,
        "title": "Chapter 1",
        "verses": [
          {
            "number": 1,
            "text": "Sehemu ya kwanza..."
          }
        ]
      }
    ]
  }
]
```

---

## 5. Field Descriptions

### Story Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | String | ✅ Yes | Story title - Keep under 100 characters |
| `author` | String | ✅ Yes | Author name - e.g., "Hassan Mwinyi" |
| `category` | String | ✅ Yes | Must match existing category in app |
| `coverImageUrl` | String | ✅ Yes | Full URL to cover image (Firebase Storage recommended) |
| `synopsis` | String | ✅ Yes | Brief summary (50-200 words) |
| `readingTimeMinutes` | Number | ✅ Yes | Estimated reading time (5-60 minutes) |
| `tags` | Array | ⚠️ Optional | Keywords for search - e.g., ["adventure", "kids"] |
| `isFeatured` | Boolean | ⚠️ Optional | Show on featured list? (true/false) |
| `content` | String | ⚠️ Optional | Full text for non-chapter stories |
| `chapters` | Array | ✅ Yes | List of chapters (can be empty array for simple stories) |

### Chapter Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `number` | Number | ✅ Yes | Chapter number (1, 2, 3...) |
| `title` | String | ✅ Yes | Chapter title - e.g., "Sura ya Kwanza: Mwanzo" |
| `imageUrl` | String | ⚠️ Optional | Chapter header image URL |
| `verses` | Array | ✅ Yes | List of verses/paragraphs |

### Verse Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `number` | Number | ✅ Yes | Verse/paragraph number (1, 2, 3...) |
| `text` | String | ✅ Yes | The actual content text |

---

## 6. Examples

### Example 1: Short Bedtime Story

```json
[
  {
    "title": "Twiga na Nyota",
    "author": "Sarah Njeri",
    "category": "Bedtime Stories",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../giraffe.jpg",
    "synopsis": "Twiga mdogo anajifunza jinsi ya kufikia nyota angani.",
    "readingTimeMinutes": 3,
    "tags": ["bedtime", "animals", "dreams"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Usiku wa Nyota",
        "verses": [
          {
            "number": 1,
            "text": "Twiga mdogo alilala chini ya mti mkubwa, akitazama nyota angani."
          },
          {
            "number": 2,
            "text": "'Nataka kugusa nyota!' alisema kwa shauku."
          },
          {
            "number": 3,
            "text": "Mama Twiga alimsogea na kumwambia, 'Ndoto zako zinaweza kukufikisha mbali zaidi ya nyota.'"
          },
          {
            "number": 4,
            "text": "Twiga mdogo alitabasamu na kulala, akiota ndoto za kufikia angani."
          }
        ]
      }
    ]
  }
]
```

### Example 2: Educational Series (Multiple Chapters)

```json
[
  {
    "title": "Mchakato wa Chakula",
    "author": "Dr. James Mwangi",
    "category": "Educational",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../digestion.jpg",
    "synopsis": "Jinsi mwili wetu unavyotumia chakula tunachokula.",
    "readingTimeMinutes": 12,
    "tags": ["educational", "health", "science"],
    "isFeatured": true,
    "chapters": [
      {
        "number": 1,
        "title": "Hatua ya Kwanza: Mdomo",
        "imageUrl": "https://firebasestorage.googleapis.com/.../mouth.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Safari ya chakula inaanza mdomoni!"
          },
          {
            "number": 2,
            "text": "Meno yako hukata chakula vipande vidogo."
          },
          {
            "number": 3,
            "text": "Mate husaidia kuchanganya chakula na kuanza kuvunja."
          }
        ]
      },
      {
        "number": 2,
        "title": "Hatua ya Pili: Tumbo",
        "imageUrl": "https://firebasestorage.googleapis.com/.../stomach.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Chakula kinaenda kwa ulimi kupitia tube ndefu hadi tumboni."
          },
          {
            "number": 2,
            "text": "Tumbo ni kama jiko! Linachanganya na kuvunja chakula kwa asidi."
          },
          {
            "number": 3,
            "text": "Mchakato huu huchukua masaa 2-4."
          }
        ]
      },
      {
        "number": 3,
        "title": "Hatua ya Tatu: Utumbo",
        "imageUrl": "https://firebasestorage.googleapis.com/.../intestines.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Chakula kinakwenda utumbo mdogo - tube ndefu sana!"
          },
          {
            "number": 2,
            "text": "Hapa, mwili unachukua virutubishi muhimu."
          },
          {
            "number": 3,
            "text": "Taka zinaenda utumbo mkubwa na kisha nje ya mwili."
          }
        ]
      }
    ]
  }
]
```

### Example 3: Fairy Tale

```json
[
  {
    "title": "Binti wa Mfalme na Chura",
    "author": "Traditional Tale",
    "category": "Fairy Tales",
    "coverImageUrl": "https://firebasestorage.googleapis.com/.../princess-frog.jpg",
    "synopsis": "Hadithi ya kale ya binti wa mfalme na chura wa ajabu.",
    "readingTimeMinutes": 8,
    "tags": ["fairy-tale", "magic", "princess"],
    "isFeatured": true,
    "chapters": [
      {
        "number": 1,
        "title": "Mpira wa Dhahabu",
        "imageUrl": "https://firebasestorage.googleapis.com/.../golden-ball.jpg",
        "verses": [
          {
            "number": 1,
            "text": "Hapo zamani, kulikuwa na binti wa mfalme mzuri sana."
          },
          {
            "number": 2,
            "text": "Alikuwa na mpira wa dhahabu ambao alipenda sana."
          },
          {
            "number": 3,
            "text": "Siku moja, mpira ulianguka kisimani!"
          }
        ]
      },
      {
        "number": 2,
        "title": "Chura wa Ajabu",
        "imageUrl": "https://firebasestorage.googleapis.com/.../talking-frog.jpg",
        "verses": [
          {
            "number": 1,
            "text": "'Nitakusaidia kupata mpira wako,' chura alisema."
          },
          {
            "number": 2,
            "text": "Binti wa mfalme alishangaa! 'Chura anazungumza!'"
          },
          {
            "number": 3,
            "text": "'Lakini utaniahidi kitu...' chura aliendelea."
          }
        ]
      }
    ]
  }
]
```

---

## 7. Tips & Best Practices

### ✅ DO:

1. **Use Chapters for Longer Stories**
   - Better reading experience
   - Easier navigation
   - Can add images to each chapter

2. **Keep Verses Short**
   - 1-3 sentences per verse
   - Makes reading easier for children
   - Better mobile experience

3. **Use Firebase Storage for Images**
   - Permanent URLs
   - Fast loading
   - Reliable hosting

4. **Match Existing Categories**
   - Check app for category names
   - Or create categories first
   - Case-sensitive matching

5. **Add Descriptive Titles**
   - Clear chapter names
   - Include chapter number
   - Use descriptive subtitles

6. **Use Tags Wisely**
   - 3-5 relevant tags
   - Help with search
   - Use lowercase

### ❌ DON'T:

1. **Don't Use Instagram URLs Directly**
   - They may expire
   - Use Firebase Storage instead
   - Or fetch with Instagram tool first

2. **Don't Make Verses Too Long**
   - Hard to read on mobile
   - Split into multiple verses
   - Keep it digestible

3. **Don't Skip Required Fields**
   - App will reject incomplete data
   - Check all required fields
   - Validate JSON first

4. **Don't Use Special Characters in URLs**
   - May cause errors
   - Use properly encoded URLs
   - Test URLs before importing

---

## 📤 How to Import

### Method 1: Paste JSON (Quick)
1. Open Admin Panel
2. Tap "Import Stories from JSON"
3. Select "Paste JSON" tab
4. Paste your JSON
5. Tap "Parse JSON"
6. Review stories
7. Tap "Import Stories"

### Method 2: Upload File (Better for Large Files)
1. Save JSON as `.json` file
2. Open Admin Panel
3. Tap "Import Stories from JSON"
4. Select "Upload File" tab
5. Choose your file
6. Review parsed stories
7. Tap "Import Stories"

---

## 🔧 Validation Tools

### Online JSON Validators:
- https://jsonlint.com/
- https://jsonformatter.org/
- https://codebeautify.org/jsonvalidator

### Check Before Importing:
1. ✅ Valid JSON syntax
2. ✅ All required fields present
3. ✅ Categories exist in app
4. ✅ Image URLs are accessible
5. ✅ Chapter numbers are sequential
6. ✅ Verse numbers are sequential

---

## 📋 Quick Reference Template

Copy this template and fill in your data:

```json
[
  {
    "title": "Your Story Title Here",
    "author": "Author Name",
    "category": "Category Name",
    "coverImageUrl": "https://your-image-url.jpg",
    "synopsis": "Short description of your story (50-200 words)",
    "readingTimeMinutes": 10,
    "tags": ["tag1", "tag2", "tag3"],
    "isFeatured": false,
    "chapters": [
      {
        "number": 1,
        "title": "Chapter Title",
        "imageUrl": "https://chapter-image-url.jpg",
        "verses": [
          {
            "number": 1,
            "text": "First paragraph or verse text here."
          },
          {
            "number": 2,
            "text": "Second paragraph or verse text here."
          }
        ]
      }
    ]
  }
]
```

---

## 🆘 Common Errors

### Error: "Invalid JSON format"
**Solution:** Validate JSON at jsonlint.com

### Error: "Category not found"
**Solution:** Create category first or check spelling

### Error: "Missing required field"
**Solution:** Check all required fields are present

### Error: "Failed to load image"
**Solution:** Verify image URL is accessible

---

**Happy Story Creating! 📚✨**

For more help, see:
- [Quick Start Guide](QUICK_START.md)
- [Admin Panel Guide](ADMIN_PANEL_COMPLETE.md)
- [Instagram Image Guide](INSTAGRAM_IMAGE_QUICK_GUIDE.md)
