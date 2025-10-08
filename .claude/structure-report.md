# 🏗️ Project Structure Report

**Generated:** Tue Oct 7 01:14:59 UTC 2025

## 📊 Directory Analysis

```
.
└── modules
    ├── ai-engine
    │   ├── core
    │   ├── data
    │   │   ├── datasets
    │   │   ├── processed
    │   │   └── raw
    │   ├── inference
    │   ├── models
    │   │   ├── audio
    │   │   ├── llm
    │   │   ├── predictive
    │   │   └── vision
    │   ├── training
    │   └── weights
    │       ├── audio_models
    │       ├── custom_models
    │       ├── llm_models
    │       └── vision_models
    ├── automation
    │   ├── deployment
    │   ├── monitoring
    │   ├── scraping
    │   └── workflows
    ├── backend
    │   ├── apps
    │   │   ├── api
    │   │   │   ├── core
    │   │   │   ├── models
    │   │   │   ├── routers
    │   │   │   ├── schemas
    │   │   │   ├── services
    │   │   │   └── utils
    │   │   ├── scheduler
    │   │   │   └── jobs
    │   │   └── worker
    │   │       └── tasks
    │   ├── packages
    │   │   ├── auth
    │   │   │   ├── middleware
    │   │   │   └── providers
    │   │   ├── database
    │   │   │   ├── migrations
    │   │   │   └── models
    │   │   └── utils
    │   │       ├── encryption
    │   │       └── validation
    │   └── tests
    ├── business-intelligence
    │   ├── analytics
    │   ├── data_pipeline
    │   └── reporting
    ├── business_intelligence
    │   ├── analytics
    │   ├── dashboards
    │   ├── data_pipeline
    │   └── reporting
    ├── frontend
    │   ├── apps
    │   │   ├── admin
    │   │   │   └── src
    │   │   │       ├── app
    │   │   │       ├── components
    │   │   │       │   ├── ai-management
    │   │   │       │   ├── analytics
    │   │   │       │   └── dashboard
    │   │   │       └── lib
    │   │   ├── mobile
    │   │   └── web
    │   │       ├── diglit-quantum
    │   │       │   ├── app
    │   │       │   ├── components
    │   │       │   │   ├── dashboard
    │   │       │   │   ├── ui
    │   │       │   │   └── voice
    │   │       │   ├── hooks
    │   │       │   ├── lib
    │   │       │   ├── public
    │   │       │   └── styles
    │   │       ├── diglit-web
    │   │       │   ├── node_modules
    │   │       │   └── src
    │   │       │       ├── components
    │   │       │       │   ├── ai
    │   │       │       │   └── ui
    │   │       │       ├── hooks
    │   │       │       └── pages
    │   │       └── src
    │   │           ├── app
    │   │           ├── components
    │   │           │   ├── ai
    │   │           │   ├── business
    │   │           │   ├── cinema
    │   │           │   ├── forms
    │   │           │   └── ui
    │   │           ├── hooks
    │   │           ├── lib
    │   │           ├── styles
    │   │           └── types
    │   └── packages
    │       ├── api-client
    │       │   └── src
    │       │       ├── assets
    │       │       ├── components
    │       │       ├── hooks
    │       │       ├── themes
    │       │       ├── tokens
    │       │       └── utils
    │       ├── design-system
    │       │   ├── dist
    │       │   ├── node_modules
    │       │   └── src
    │       │       ├── assets
    │       │       ├── components
    │       │       ├── hooks
    │       │       ├── themes
    │       │       ├── tokens
    │       │       └── utils
    │       └── ui
    │           └── src
    │               ├── assets
    │               ├── components
    │               ├── hooks
    │               ├── themes
    │               ├── tokens
    │               └── utils
    ├── visual-engine
    │   ├── effects
    │   ├── exports
    │   │   ├── brand_packages
    │   │   ├── generated_images
    │   │   ├── rendered_videos
    │   │   └── ui_components
    │   ├── generators
    │   └── templates
    │       ├── brand_assets
    │       ├── business_presentations
    │       ├── mobile_interfaces
    │       ├── social_media_templates
    │       └── web_layouts
    └── visual_engine
        ├── effects
        ├── exports
        ├── generators
        ├── shaders
        └── templates

42 directories, 105 files
```

## 📁 Module Status

### ai-engine

- **Files**: 8
- **Directories**: 18
- **Status**: 🟢 ACTIVE

### automation

- **Files**: 1
- **Directories**: 5
- **Status**: 🟢 ACTIVE

### backend

- **Files**: 6
- **Directories**: 24
- **Status**: 🟢 ACTIVE

### business-intelligence

- **Files**: 1
- **Directories**: 4
- **Status**: 🟢 ACTIVE

### business_intelligence

- **Files**: 4
- **Directories**: 5
- **Status**: 🟢 ACTIVE

### frontend

- **Files**: 154
- **Directories**: 107
- **Status**: 🟢 ACTIVE

### visual-engine

- **Files**: 1
- **Directories**: 14
- **Status**: 🟢 ACTIVE

### visual_engine

- **Files**: 3
- **Directories**: 6
- **Status**: 🟢 ACTIVE

## 💡 Recommendations

1. **Fill empty modules** with actual code
2. **Remove truly unused directories**
3. **Verify module dependencies**
4. **Update package.json files** with proper scripts

## 🚀 Next Steps

Run the cleanup regularly to maintain optimal structure:

```bash
npm run structure:cleanup
```
