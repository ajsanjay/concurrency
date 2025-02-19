//
//  DownloadImageAsyncLern.swift
//  SwiftConcurrency
//
//  Created by Jaya Sabeen on 19/02/25.
//

import SwiftUI
import Combine

class DownloadImageAsyncLoader {
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode <= 300 else {
            return nil
        }
        return image
    }
    
    func downloadUsingEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            let image = self.handleResponse(data: data, response: response)
            completionHandler(image, error)
        }
        .resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
    
}

class DownloadImageAsyncVM: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncLoader()
    var cancellabel = Set<AnyCancellable>()
    
    func getImage() {
//        self.image = UIImage(systemName: "heart.fill")
       /* loader.downloadUsingEscaping { [weak self] image, error in
            //self?.image = image //-> This throws thread unsafe error
            DispatchQueue.main.async {
                self?.image = image
            }
        }*/
        
       /* loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] image in
                self?.image = image
            }
            .store(in: &cancellabel)*/
        
    }
    
    func getImageConcurrency() async {
        let image = try? await loader.downloadWithAsync()
//        self.image = image //-> this trows run time error
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsyncLern: View {
    
    @StateObject private var viewModel = DownloadImageAsyncVM()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear() {
            Task {
                await viewModel.getImageConcurrency()
            }
        }
    }
}

#Preview {
    DownloadImageAsyncLern()
}
