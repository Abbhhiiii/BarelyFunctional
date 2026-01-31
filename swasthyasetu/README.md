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

The `swasthyasetu` Flutter app currently implements the following features. This README documents what exists in the codebase and how to run it locally.

- **Authentication & Role Redirects**: Sign in and automatic routing to `DoctorDashboard`, `PatientDashboard`, or `GovWorkerDashboard` based on stored role.
- **Appointments**: Appointment creation (doctors/gov-workers) stored under `appointments`. Patients see their scheduled appointments in their dashboard.
- **Prescriptions**: Doctors can add prescriptions via the Manage Appointments flow. Prescriptions are saved to the appointment document and propagated to the patient's `users` document as `lastPrescription`.
- **Profiles & Gov-worker patient management**: Profile screens for patients/doctors/gov workers are styled cards. Gov workers can add/manage manual patient entries stored in `patients`.
- **Symptom Reporting & SOS**: Patients can submit symptom reports (slider-based) saved in `symptoms_reports`; a Manual SOS flow creates emergency reports.
- **Management Pages**: `ManageAppointmentsPage` (doctor) and `ManagePatientsPage` (gov worker) let staff view, update, and add prescription/health data.
- **UI/UX improvements**: Unified background color, keyboard-safe sign-in, improved card/list layouts, and aesthetic profile headers.
- **Firestore Collections Used**: `users`, `patients`, `appointments`, `symptoms_reports`.

Development notes and run instructions are included below.
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
