import service from '../request'


interface Students {
  id: number,
  name: string,
  age: number,
  gender: string
}

export const getStudentAll = () => service.get<any,any>('/students');
export const addStudents = (student:Students) => service.post('/students', student);
export const reqUpdateStudent = (student: Students) => service.put('/students/'+student.id, student)

export const reqDeleteStudent = (id: number) => service.delete('/students/'+id)