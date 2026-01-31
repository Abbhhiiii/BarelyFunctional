# SwasthyaSetu
# BareFunctional

## Mandatory Header Information

**Project Name:** SwasthyaSetu
**Problem Statement ID:** CS02HA 
**Team Name:** BarelyFunctional
**College Name:** St. Joseph Engineering College, Mangalore

---

## 📌 Problem Statement

A large portion of the population lacks access to continuous healthcare due to limited digital access, irregular medical checkups, poor follow-up systems, and low awareness of preventive healthcare. Existing solutions often assume smartphone ownership, digital literacy, and self-initiated health tracking, which excludes vulnerable groups such as elderly patients, women in underserved areas, and low-income families.

There is a critical need for a **hybrid healthcare system** that bridges the gap between **manual health workers, hospitals, and end users**, while supporting **low-tech access**, local languages, and timely medical interventions.

---

## 💡 Solution Overview

**SwasthyaSetu** is a unified health-tracking and communication platform integrating **ASHA workers, hospitals, doctors, patients, and mobile medical units**.

The app enables:

- Manual data entry by health workers for people without phones
- Alerts and notifications for patients
- Doctor-driven follow-ups and medicine tracking
- Symptom-based alerts and emergency escalation
- Mental health and women-centric healthcare support
- Multilingual and voice-assisted accessibility

---

## 👥 User Roles

### 1️⃣ ASHA Worker

- Creates and manages profiles for users without smartphones
- Conducts weekly/manual health checkups
- Enters vital data and symptoms during visits
- Acts as a bridge between patients and hospitals

### 2️⃣ Hospital / Doctors

- Create doctor profiles under the hospital account
- Receive alerts based on patient symptoms
- Provide call-based consultations
- Raise **“Must Visit Hospital”** alerts by entering patient numbers
- Schedule follow-up visits and medical checkups
- Prescribe medicines with timing and color-coded identification

### 3️⃣ End Users (Patients)

- Receive app notifications and in-app interactions
- Nominate family members to receive alerts on their behalf
- Symptom selection using image-based intensity sliders
- Emergency SOS access
- Medicine reminders using **color and time-based alerts**

### 4️⃣ Mobile Medical Unit / Van Staff

- Perform on-site medical checkups
- Update patient records during field visits
- Coordinate with hospitals for escalations

---

## 🩺 Key Features (Implemented)

This repository contains the SwasthyaSetu mobile app with the following implemented features (reflecting the current codebase):

- **Authentication & Role Redirects**: Users sign in and are redirected based on role (`doctor`, `patient`, `gov_worker`).
- **Appointments**: Doctors (or authorized users) can schedule appointments stored in the `appointments` collection; patients can view their appointments.
- **Prescriptions**: Doctors can add prescriptions to appointments; prescriptions are saved on the appointment document and mirrored to the patient's `users` record as `lastPrescription`.
- **Profile Views**: Simple but styled profile pages exist for patients, doctors, and government workers. Gov workers can add manual patient records saved in the `patients` collection.
- **Symptom Reporting & SOS**: Patients can submit symptom reports (slider-based inputs) which are stored in `symptoms_reports`. A manual SOS flow triggers an alert record when severe symptoms are reported.
- **Management UIs**: Doctor-facing `Manage Appointments` and gov-worker-facing `Manage Patients` pages let staff view and update records, and add prescriptions or health updates.
- **Client-side Safety & UX improvements**: Keyboard-safe sign-in, unified background color, styled profile cards, and improved list/card layouts for appointment and patient displays.
- **Firebase-backed storage**: The app uses Firestore collections: `users`, `patients`, `appointments`, and `symptoms_reports`.

Notes: the README focuses on features implemented in the current code. For dev setup and Firebase configuration see the app README below.
---

## 🏗️ System Architecture (High Level)

- **Frontend:** Mobile Application (Android-first)
- **Backend:** Centralized server for user data & alerts
- **Communication Layer:** SMS, Push Notifications
- **Database:** Secure medical record storage
- **Access Control:** Role-based permissions

---

## 🚀 Impact

- Brings healthcare access to people without smartphones
- Reduces missed checkups and medicine non-compliance
- Enables faster emergency response
- Strengthens preventive healthcare
- Empowers ASHA workers with digital tools
- Improves doctor-patient communication

---

## 🧑‍💻 Team

**Team Name:** BarelyFunctional
**College:** St. Joseph Engineering College, Mangalore

---

## 📄 License

This project is developed as part of a hackathon and is intended for educational and social impact purposes.

---
