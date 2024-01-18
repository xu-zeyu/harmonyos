import { getStudentAll, addStudents,reqUpdateStudent,reqDeleteStudent } from '../api/index'

interface Students {
  id: number,
  name: string,
  age: number,
  gender: string
}


@CustomDialog
struct CustomDialogExample {
  @Link customType: string
  @Link Student: Students

  controller: CustomDialogController
  // 若尝试在CustomDialog中传入多个其他的Controller，以实现在CustomDialog中打开另一个或另一些CustomDialog，那么此处需要将指向自己的controller放在最后
  cancel: () => void
  confirm: () => void

  @Styles
  inputStyles() {
    .layoutWeight(1)
    .padding({ left: 0 })
    .borderRadius(0)
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 } })
  }

  build() {
    Column() {
      Text(this.customType === 'ADD'? '新增' : '编辑')
        .fontSize(20)
        .margin({
          bottom:10
        })
      Row() {
        Text('姓名').margin({ right: 20 })
        TextInput({ text: this.Student.name, placeholder: '请输入姓名' })
          .inputStyles()
          .onChange(val =>this.Student.name = val)

      }.width('100%')
      Row() {
        Text('年龄').margin({ right: 20 })
        TextInput({ text: String(this.Student.age), placeholder: '请输入年龄' })
          .type(InputType.Number)
          .inputStyles()
          .onChange((val:string) => this.Student.age = Number(val))

      }.width('100%').margin({top:10})

      Row() {
        Text('性别').margin({right: 20})
        Select([{value: '男'}, {value: '女'}])
          .value('男')
          .width(50)
          .onSelect((index, val) => this.Student.gender = val)
      }
      .width('100%')
      Row({space:40}){
        Button('取消').backgroundColor('#ccc').onClick(()=>{
          this.controller.close()
          this.cancel()
        })
        Button('确定').onClick(()=>{
          this.controller.close()
          this.confirm()
        })
      }.width('100%').justifyContent(FlexAlign.Center).margin({top:10})

    }.width('100%').borderRadius(14).padding(20).backgroundColor(Color.White)
  }
}

@Entry
@Component
struct Second {
  @State students: Students[] = []
  @State popupType: string = 'ADD'
  @State selectStud: Students = null

  async findStudent() {
    let res = await getStudentAll()
    this.students = res
    console.log(JSON.stringify(this.students))
  }

  async addStudent() {
    this.popupType = 'ADD'
    this.selectStud = {
      id:0,
      name: '',
      age: 0,
      gender: '男'
    }
    this.dialogController.open()
  }

  async editStudent(item:Students) {
    this.popupType = 'EDIT'
    this.selectStud = item
    this.dialogController.open()
  }


  //弹窗关闭回调
  async onCancel() {
    console.log('onCancel')
  }

  // 弹窗确定回调
  onAccept =  async () => {
    if (this.selectStud.id) {
      await reqUpdateStudent(this.selectStud)
    } else {
      await addStudents(this.selectStud)
    }
    this.findStudent()
  }

  // 点击通障层退出时的回调
  existApp() {
    console.info('Click the callback in the blank area')
  }

  dialogController: CustomDialogController = new CustomDialogController(
    {
      builder: CustomDialogExample({
        customType: $popupType,
        Student: $selectStud,
        cancel: this.onCancel.bind(this),
        confirm: this.onAccept,
      }),
      autoCancel: true, //是否允许点击遮障层退出。默认值: true
      alignment: DialogAlignment.Center, //弹窗在竖直方向上的对齐方式，默认值: DialogAlignment.Default
      offset: { dx: 0, dy: -20 }, //弹南相对alignment所在位置的偏移量。
      gridCount: 4, //，弹窗宽度占栅格宽度的个数
      customStyle: false //弹窗容器样式是否自定义。
    }
  )

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = undefined // 将dialogController置空
  }
  aboutToAppear(){
    this.findStudent()
  }



  build() {
    Column({
      space: 20
    }) {
      Row() {
        Text('学生列表').fontSize(30)
        Blank()
        Button('+')
          .width(50)
          .fontSize(28)
          .onClick(() => {
            this.addStudent()
          })
      }
      .width('100%')
      .height(60)
      .border({
        width: { bottom: 1 },
        color: Color.Black
      })

      List({
        space: 20
      }) {
        ForEach(this.students, (item: Students) => {
          ListItem() {
            Row(){
              Text(item.name).fontSize(20)
              Text(String(item.age)).fontSize(20)
              Text(item.gender).fontSize(20)
              Button('更新').onClick(()=>{
                this.editStudent(item)
              })
              Button('删除').onClick(()=>{
                AlertDialog.show(
                  {
                    title: '警告',
                    message: '确定删除吗?',
                    autoCancel: true,
                    alignment: DialogAlignment.Center,
                    gridCount: 4,
                    offset: { dx: 0, dy: -20 },
                    primaryButton: {
                      value: '取消',
                      action: () => {
                        console.info('Callback when the first button is clicked')
                      }
                    },
                    secondaryButton: {
                      value: '确定',
                      action: async () => {
                      await reqDeleteStudent(item.id)
                        this.findStudent()
                      }
                    },
                    cancel: () => {
                      console.info('Closed callbacks')
                    }
                  }
                )
              })
            }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({left:8,right:8})
          }.width('100%').height(60).backgroundColor(Color.White).borderRadius(12)
        }, (item,index) =>  index + JSON.stringify(item))
      }.width('100%').layoutWeight(1)
    }.width('100%').padding(12).backgroundColor('#ccc')
  }
}





