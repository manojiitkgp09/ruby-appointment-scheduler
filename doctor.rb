#!/usr/bin/ruby
require 'scanf.rb'
class Office
  DOCTOR_NAMES_LIST = ["Ram", "Shyam", "Krishna", "Shiva", "Vishnu"]
  def initialize
    @doctors = []
   DOCTOR_NAMES_LIST.each do |name|
      doctor = Doctor.new(name, nil, nil, nil)
      @doctors.push(doctor)
    end
  end

  def doctors_list
    return DOCTOR_NAMES_LIST
  end

  def getDoctor(name)
    selectedDoctorIndex = @doctors.index{|doctor| doctor.name == name}
    if (selectedDoctorIndex != nil)
      return @doctors.at(selectedDoctorIndex)
    else 
      return nil
    end
  end
end

class Doctor
  def initialize(name, start_time, end_time, durationInMins)
    @name = name
    start_time = start_time || Time.new(2013, 'jan', 24, 8, 0, 0)
    end_time = end_time || Time.new(2013, 'jan', 24, 18, 0, 0)
    durationInMins = durationInMins || 60
    @appointment = Appointment.new(@name)
    @appointment.createSlots(start_time,end_time, durationInMins,@name)
  end

  def name
    @name
  end

  def appointment
    @appointment
  end

  def getAvailableAppointmentSlots
    available_slots = @appointment.getAvailableSlots()
    available_slots
  end

  def getOccupiedAppointmentSlots
    occupied_slots = @appointment.getOccupiedSlots()
    occupied_slots
  end
end

class Patient
  def initialize(name)
    @name = name
  end

  def name
    @name
  end
  
  def bookAppointment(office, slotNumber, doctor_name)
    doctor = office.getDoctor(doctor_name)
    if (!doctor.nil?)
      doctor_appointment = doctor.appointment
      available_slots = doctor_appointment.getAvailableSlots()
      selected_slot_index = available_slots.index{|slot| slot.number == slotNumber}
      if (selected_slot_index.nil?)
        return "No such slot available"
      end
      available_slots[selected_slot_index].book(@name)
      return "Slot Booked"
    else 
      return "No doctor found"
    end
  end
end

class Appointment
  def initialize(name)
    @slots = []
  end

  def createSlots(stime, etime, duration, name)
    (1..(etime-stime)/(60*duration)).each do |slot_number|
      start_time = stime+(slot_number-1)*duration*60
      end_time = start_time+duration*60
      slot = Slot.new(slot_number, start_time, end_time, true, "")
      @slots.push(slot)
    end
  end

  def getAvailableSlots
    @slots.select{|slot| slot.availablity}
  end

  def getOccupiedSlots
    @slots.select{|slot| !slot.availablity}
  end

end

class Slot
  def initialize(number, stime, etime, availablity, patient_name)
    @number = number
    @stime = stime.hour.to_s+":"+stime.min.to_s
    @etime = etime.hour.to_s+":"+etime.min.to_s
    @availablity = availablity
    @patient_name = patient_name
  end
  
  def availablity
    @availablity
  end
  
  def stime
    @stime
  end

  def etime
    @etime
  end

  def number
    @number
  end

  def patient_name
    @patient_name
  end

  def book(patient_name)
    @availablity = false
    @patient_name = patient_name
  end
end

office = Office.new()
patient_name = ""
puts "Welcome to Your Clinic"
while(patient_name != "exit") do
  puts "Please enter your first name, avoid white space, type exit to quit:"
  patient_name = scanf("%s")
  patient_name = patient_name.join(" ")
  if (patient_name != "exit")
    patient = Patient.new(patient_name)
    puts "Hello "+patient.name
    available_appointment_slots = []
    count = 0
    no_of_doctors = office.doctors_list().length
    
    while(available_appointment_slots.empty? && count < no_of_doctors) do
      count = count+1
      selected_doctor = nil
      while(selected_doctor == nil) do
        puts "Please type the name of the doctor from the list as per your preference"
        puts office.doctors_list().inspect
        doctor_name = scanf("%s")
        doctor_name = doctor_name.join(" ")
        selected_doctor = office.getDoctor(doctor_name)
      end
      available_appointment_slots = selected_doctor.getAvailableAppointmentSlots()
    end
    
    if (count != no_of_doctors)
      puts "Available slots"
      available_appointment_slots.each{|slot| puts "Slot Number #{slot.number}: #{slot.stime} to #{slot.etime} "}  
      puts "Enter your preferred slot number"
      slot = scanf("%d")
      selected_slot = slot[0]
      appointment_status = patient.bookAppointment(office, selected_slot, doctor_name)
      puts appointment_status
      puts "Occupied slots for #{doctor_name}"
      occupied_slots = selected_doctor.getOccupiedAppointmentSlots()
      occupied_slots.each{|slot| puts "Slot Number #{slot.number}: #{slot.stime} to #{slot.etime}, Patient Name: #{slot.patient_name} "}
      puts "Remaining available slots for #{doctor_name}"
      remaining_available_slots = selected_doctor.getAvailableAppointmentSlots()
      remaining_available_slots.each{|slot| puts "Slot Number #{slot.number}: #{slot.stime} to #{slot.etime} "}  
    else
      puts "Sorry, No Doctor Available"
      patient_name = "exit"
    end
  end
end
