import pymongo
from datetime import datetime
from bson.objectid import ObjectId

# MongoDB connection (adjust URI as needed)
client = pymongo.MongoClient("mongodb://localhost:27017/")
db = client["news_db"]
news_collection = db["News_reserve"]

db["Comments"].drop()
db["Users"].drop()
db["News_reserve"].drop()

# Predefined diverse mock news articles
mock_news = [
        {
            "headline": "Global Aviation Fuel Market to Soar from USD 238.2 B in 2024 to USD 474.9 B by 2034",
            "excerpt": "The aviation fuel market is projected to double over the next decade driven by rising air travel, strategic collaborations, and sustainable fuel advancements.",
            "positivity": 80,
            "category": "business",
            "full_body": "According to a new ResearchAndMarkets report, the global aviation fuel market was valued at USD 238.2 billion in 2024 and is forecast to reach USD 474.9 billion by 2034, growing at an 8.20% CAGR. Growth drivers include surging passenger traffic, increased freight transport, strategic supply-chain partnerships, and rising investment in sustainable aviation fuels amid stricter emissions regulations. North America—where the market was worth USD 57.9 billion in 2024—is expected to maintain robust growth alongside Asia-Pacific's rapid air travel expansion.",
            "created_date": datetime.utcnow(),
            "source_url": "https://www.globenewswire.com/news-release/2025/05/05/3073828/28124/en/Global-Aviation-Fuel-Market-Set-to-Double-by-2034-amid-Rising-Air-Travel-Demand.html",
            "orig_headline": "Global Aviation Fuel Market Set to Double by 2034 amid Rising Air Travel Demand"
        },
        {
            "headline": "Ithaca Goes Fully Green: Town Achieves 100% Renewable Energy",
            "excerpt": "After installing 15,000 solar panels and three turbines, Ithaca now meets all its power needs sustainably.",
            "positivity": 92,
            "category": "science",
            "full_body": "Officials in Ithaca announced today that the combination of rooftop solar arrays and a new wind farm has enabled the town to run entirely on renewables, cutting CO₂ emissions by 70% compared to last year.",
            "created_date": datetime.utcnow(),
            "source_url": "https://www.reuters.com/business/energy/ithaca-100-renewable-energy-2025-05-07/",
            "orig_headline": "Breakthrough in Renewable Energy Powers Small Town",
        },
    {
        "headline": "Portland Trail Blazers Raise $75,000 for Doernbecher Children's Hospital",
        "excerpt": "In a packed Moda Center, the Blazers combined a win with a home-run charity auction.",
        "positivity": 85,
        "category": "sports",
        "full_body": "Fans and players rallied behind the charity game, with ticket proceeds and a live auction helping the children’s hospital expand its pediatric care wing.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.espn.com/nba/story/_/id/37289123/blazers-raise-75000-doernbecher-children-hospital",
        "orig_headline": "Local Sports Team Rallies for Charity",
    },
    {
        "headline": "US Tech Startups See 30% Drop in Series A Funding in Q1 2025",
        "excerpt": "A slowdown in venture capital has founders pivoting to revenue-based models.",
        "positivity": 40,
        "category": "business",
        "full_body": "According to PitchBook data, total U.S. venture funding fell to $50 billion in Q1, down from $72 billion a year ago, forcing many startups to extend runway and cut burn rates.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.reuters.com/technology/us-tech-startup-funding-decline-q1-2025-05-07/",
        "orig_headline": "Tech Startups Face Funding Challenges in 2025",
    },
    {
        "headline": "Brooklyn Community Garden Brings Neighbors Together in Williamsburg",
        "excerpt": "Urban residents find connection and fresh produce in shared green spaces.",
        "positivity": 78,
        "category": "lifestyle",
        "full_body": "Volunteers planted over 200 vegetable beds and ornamental flowers, hosting weekly workshops on composting and sustainable gardening.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.nytimes.com/2025/05/07/nyregion/brooklyn-community-garden-williamsburg.html",
        "orig_headline": "Community Garden Brings Neighbors Together",
    },
    {
        "headline": "2025 Presidential Debate Sparks Mixed Reactions on Economy and Healthcare",
        "excerpt": "Viewers remain divided after heated exchanges on stimulus and insurance reform.",
        "positivity": 30,
        "category": "politics",
        "full_body": "Both candidates defended their plans vigorously, but polls show 48% thought Candidate A won while 46% favored Candidate B, leaving the electorate uncertain.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.cnn.com/2025/05/07/politics/presidential-debate-mixed-reactions/index.html",
        "orig_headline": "Political Debate Sparks Mixed Reactions",
    },
    {
        "headline": "FDA Grants Fast-Track Status to First Gene Therapy for Spinal Muscular Atrophy",
        "excerpt": "Early trials show 60% improvement in motor function among young patients.",
        "positivity": 88,
        "category": "health",
        "full_body": "BioPharma Inc.'s experimental therapy ZynVax received fast-track designation after demonstrating safety and efficacy in phase 1/2 trials.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.fda.gov/news-events/press-announcements/fda-approves-first-gene-therapy-spinal-muscular-atrophy",
        "orig_headline": "Breakthrough Drug Offers Hope for Rare Disease",
    },
    {
        "headline": "Amazon to Cut 10,000 Jobs Amid Cloud Division Restructuring",
        "excerpt": "The tech giant cites shifting market demands and efficiency goals.",
        "positivity": 20,
        "category": "tech",
        "full_body": "Amazon Web Services will reduce its workforce by roughly 8% globally, reallocating resources toward AI and machine learning initiatives.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.bloomberg.com/news/articles/2025-05-07/amazon-to-cut-10000-jobs-amid-cloud-push",
        "orig_headline": "Tech Giant Announces Layoffs Amid Restructuring",
    },
    {
        "headline": "Kew Scientists Identify New Orchid Species in Amazon Rainforest",
        "excerpt": "The discovery highlights urgent conservation needs in a biodiversity hotspot.",
        "positivity": 95,
        "category": "science",
        "full_body": "A joint expedition from the Royal Botanic Gardens, Kew, and Universidade de São Paulo catalogued the purple-petaled orchid, naming it *Oncidium novum*.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.nature.com/articles/d41586-025-01347-2",
        "orig_headline": "Scientists Discover New Species in Amazon",
    },
    {
        "headline": "Global Travel Demand Rises 10% in April, Still Below Pre-Pandemic Levels",
        "excerpt": "Airlines and hotels report improved bookings, with business travel lagging.",
        "positivity": 55,
        "category": "travel",
        "full_body": "IATA reports a gradual recovery, driven by leisure travel in Europe and Asia, but corporate trips remain 25% down from 2019 figures.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.reuters.com/business/global-travel-demand-2025-05-07/",
        "orig_headline": "Travel Industry Sees Slow Recovery Post-Pandemic",
    },
    {
        "headline": "Cannes Film Festival Spotlights Underrepresented Filmmakers",
        "excerpt": "Critics praise an album of films exploring gender and racial identity.",
        "positivity": 80,
        "category": "entertainment",
        "full_body": "A record ten films directed by women and filmmakers of color received top honors, marking a shift in festival programming diversity.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.theguardian.com/film/2025/may/07/cannes-2025-diversity",
        "orig_headline": "Film Festival Celebrates Diverse Voices",
    },
    {
        "headline": "European Electric Vehicle Sales Surge by 45% in Q1 2025",
        "excerpt": "Record sales in Germany and France drive EV market growth across the EU.",
        "positivity": 75,
        "category": "business",
        "full_body": "Data from the European Automobile Manufacturers Association shows combined EV registrations hit 1.2 million units, with incentives bolstering consumer uptake.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.reuters.com/business/autos-transportation/europe-ev-sales-surge-q1-2025-05-07/",
        "orig_headline": "Electric Vehicle Adoption Surges in Europe",
    },
    {
        "headline": "Supreme Court Tightens Rules on Digital Data Privacy in 5-4 Ruling",
        "excerpt": "The narrow decision mandates clearer consent for online tracking.",
        "positivity": 50,
        "category": "politics",
        "full_body": "In a closely watched case, the Court ruled that websites must obtain explicit opt-in consent before collecting personal browsing data.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.nytimes.com/2025/05/07/us/supreme-court-data-privacy.html",
        "orig_headline": "Supreme Court Ruling Redefines Data Privacy Standards",
    },
    {
        "headline": "London Gallery Opens Immersive Climate Change Art Exhibit",
        "excerpt": "Artists transform recycled plastics into large-scale installations.",
        "positivity": 82,
        "category": "lifestyle",
        "full_body": "Curators at Tate Modern commissioned ten artists to highlight environmental crises through interactive multimedia sculptures.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.bbc.com/culture/article/20250507-climate-change-art-exhibition",
        "orig_headline": "New Art Exhibition Explores Climate Change",
    },
    {
        "headline": "6.7-Magnitude Quake Strikes Los Angeles Metro Area",
        "excerpt": "Power outages and structural damage reported in multiple neighborhoods.",
        "positivity": 10,
        "category": "science",
        "full_body": "The U.S. Geological Survey recorded the quake at 10 km depth; emergency services have opened shelters for displaced residents.",
        "created_date": datetime.utcnow(),
        "source_url": "https://apnews.com/article/california-earthquake-los-angeles-2025-05-06",
        "orig_headline": "Major Earthquake Strikes Southern California",
    },
    {
        "headline": "New Antibody Therapy Slows Alzheimer’s Progression by 25%",
        "excerpt": "Phase 2 trial results show promise for memory retention.",
        "positivity": 90,
        "category": "health",
        "full_body": "Biogen’s investigational drug ADX-102 demonstrated statistically significant benefits in cognitive tests over a 12-month period.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.nature.com/articles/nn.4567",
        "orig_headline": "Breakthrough in Alzheimer’s Research",
    },
    {
        "headline": "Portland Farmers Market Launches App for Home Delivery",
        "excerpt": "Shoppers can now order fresh produce from 30 local vendors online.",
        "positivity": 70,
        "category": "business",
        "full_body": "The new platform integrates real-time inventory and supports contactless payments, boosting vendor revenue by 15% in its first week.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.washingtonpost.com/business/2025/05/07/farmers-market-online-platform/",
        "orig_headline": "Local Farmers Market Launches Online Platform",
    },
    {
        "headline": "UK Pilot Lets AI Chatbots Provide Basic Legal Advice to Citizens",
        "excerpt": "The program aims to increase access to justice in underserved areas.",
        "positivity": 65,
        "category": "tech",
        "full_body": "Developed by LawTech UK, the chatbot answered 1,000+ queries on tenancy and employment rights during its first month.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.bbc.com/news/technology-57412345",
        "orig_headline": "AI Chatbots Now Offer Legal Advice in UK Pilot",
    },
    {
        "headline": "India Swelters Through Record 50°C Heatwave, Authorities Warn of Water Shortages",
        "excerpt": "Cities from Delhi to Jaipur break previous temperature highs.",
        "positivity": 20,
        "category": "science",
        "full_body": "Meteorological data confirm the heatwave is the worst since 1947; relief camps distribute water and electrolytes to vulnerable populations.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.theguardian.com/world/2025/may/07/india-heatwave-record-temperatures",
        "orig_headline": "Record Heatwave Shatters Temperature Records in India",
    },
    {
        "headline": "Real Madrid Drawn Against Bayern Munich in Champions League Final",
        "excerpt": "Fans celebrate as two European giants prepare for a blockbuster match.",
        "positivity": 88,
        "category": "sports",
        "full_body": "The draw sets up a rematch of the 2018 final, promising global TV audiences and high ticket demand.",
        "created_date": datetime.utcnow(),
        "source_url": "https://www.uefa.com/uefachampionsleague/news/0275-152eb6e21aac-89c7d2978a0d-1000/",
        "orig_headline": "Champions League Final Draw Brings Excitement",
    },
    {
        "headline": "New Study Links REM Sleep Duration to Lower Anxiety Levels",
        "excerpt": "Researchers analyze data from 5,000 participants across three continents.",
        "positivity": 80,
        "category": "health",
        "full_body": "Published in JAMA Psychiatry, the study finds that each extra hour of REM sleep correlates with a 15% reduction in self-reported anxiety symptoms.",
        "created_date": datetime.utcnow(),
        "source_url": "https://jamanetwork.com/journals/jamapsychiatry/fullarticle/2765932",
        "orig_headline": "New Study Links Sleep Quality to Mental Health",
    },
]
# Insert mock news articles
result = news_collection.insert_many(mock_news)
print(f"Inserted {len(result.inserted_ids)} mock news articles.")