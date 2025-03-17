//
//  AsyncAwaitLearn.swift
//  SwiftConcurrency
//
//  Created by Jaya Sabeen on 19/02/25.
//

import SwiftUI

class AsyncAwaitLearnVM: ObservableObject {
    @Published var dataArr: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArr.append("Title 1 Thread: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let title = "Title 2 Thread: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArr.append(title)
                
                let title1 = "Title 3 Thread: \(Thread.current)"
                self.dataArr.append(title1)
            }
        }
    }
    
    func addAuthor1() async {
        let author1 = "Author 1: \(Thread.current)"
        self.dataArr.append(author1)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let author2 = "Author 2: \(Thread.current)"
        
        await MainActor.run(body: {
            self.dataArr.append(author2)
            
            let author3 = "Author 3: \(Thread.current)"
            self.dataArr.append(author3)
        })
        
//        await addSomeThing()
    }
    
    func addSomeThing() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        let someThing1 = "SomeThing 1: \(Thread.current)"
        
        await MainActor.run(body: {
            self.dataArr.append(someThing1)
            
            let someThing2 = "SomeThing 2: \(Thread.current)"
            self.dataArr.append(someThing2)
        })
        
    }
}

struct AsyncAwaitLearn: View {
    
    @StateObject private var viewModel = AsyncAwaitLearnVM()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArr, id: \.self) { data in
                Text(data)
            }
        }
        .onAppear() {
            Task {
                await viewModel.addAuthor1()
                await viewModel.addSomeThing()
                let finalText = "Final Text : \(Thread.current)"
                viewModel.dataArr.append(finalText)
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

#Preview {
    AsyncAwaitLearn()
}
