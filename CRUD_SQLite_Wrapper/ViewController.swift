//
//  ViewController.swift
//  CRUD_SQLite_Wrapper
//
//  Created by Mateus Rodrigues Santos on 26/07/19.
//  Copyright © 2019 Mateus Rodrigues Santos. All rights reserved.
//

import UIKit
import SQLite

enum errosSQLite: Error {
    case erroNoCriarTabela
    case erroNoInserir
    case erroNoLer
    case erroNoUpdate
    case erroNoDelete
}

class Cliente {
    var id:Int?
    var nome:String?
    
    init(id: Int,nome:String) {
        self.id = id
        self.nome = nome
    }
    
    init() {
        
    }
}



class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet weak var nomeOriginal: UITextField!
    @IBOutlet weak var nomeAlterar: UITextField!
    
    var arrayCliente = [Cliente]()
    var clienteSelecionado = Cliente()
    
    var indexExclusao = Int()
    var indexAlteracao = Int()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCliente.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CelulaCustomizada
        cell.nome.text = arrayCliente[indexPath.row].nome
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nomeOriginal.text = arrayCliente[indexPath.row].nome
        nomeAlterar.text = arrayCliente[indexPath.row].nome
        clienteSelecionado.id = arrayCliente[indexPath.row].id
        clienteSelecionado.nome = arrayCliente[indexPath.row].nome
        indexAlteracao = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        clienteSelecionado.id = arrayCliente[indexPath.row].id
        clienteSelecionado.nome = arrayCliente[indexPath.row].nome
        indexExclusao = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //Delete
            arrayCliente.remove(at: indexExclusao)
            tableView.reloadData()
            let num:Int64 = Int64(clienteSelecionado.id!)
            do{
                let clienteProcurado = cliente.filter(id == num)
                if try (db?.run(clienteProcurado.delete()))! >  0{
                    print("Excluído com sucesso!!!")
                }else{
                    print("Erro no excluir!!!")
                }
            }catch{
                print(errosSQLite.erroNoDelete)
            }
        }
    }

 
    var db: Connection? = nil
    let cliente = Table("Cliente")
    let id = Expression<Int64>("id")
    let nome = Expression<String>("nome")
    
    func adicionaArquivoNoDocuments() -> URL{
        let urlDocument = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return urlDocument.appendingPathComponent("amigos").appendingPathExtension("db")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let path = adicionaArquivoNoDocuments()
        db = try? Connection(path.path)
        
        print(path.path)
        
        //Criar tabela
        
        do{
            try db?.run(cliente.create{ c in
                c.column(id,primaryKey: true)
                c.column(nome,unique: true)})
        }catch{
            print(errosSQLite.erroNoCriarTabela)
        }
        
 
        //Ler
        do{
            for clientes in try (db?.prepare(cliente))!{
                print("Id: \(clientes[id]) Nome: \(clientes[nome])")
                let cliente = Cliente.init(id: Int(clientes[id]), nome: clientes[nome])
                arrayCliente.append(cliente)
            }
        }catch{
            print(errosSQLite.erroNoLer)
        }

 

        //Queries elaboradas

        //Ler
        do{
            for clientes in try (db?.prepare(cliente))!{
                print("Id: \(clientes[id]) Nome: \(clientes[nome])")
            }
        }catch{
            print(errosSQLite.erroNoLer)
        }
        
    }
    
    @IBAction func alterar(_ sender: Any) {
        //Update
        if !self.nomeAlterar.text!.isEmpty {
            
            let num:Int64 = Int64(clienteSelecionado.id!)
            do{
                let clienteProcurado = cliente.filter(id == num)
                if try (db?.run(clienteProcurado.update(nome <- nomeAlterar.text!)))! >  0{
                    print("Atualizado com sucesso!!!")
                    arrayCliente[indexAlteracao].nome = nomeAlterar.text!
                    self.loadView()
                }else{
                    print("Erro na atualização!!!")
                }
            }catch{
                print(errosSQLite.erroNoUpdate)
            }
        }
        //Ler
        do{
            for clientes in try (db?.prepare(cliente))!{
                print("Id: \(clientes[id]) Nome: \(clientes[nome])")
            }
        }catch{
            print(errosSQLite.erroNoLer)
        }
    }


    @IBAction func inserir(_ sender: Any) {
        //Inserir
        if !self.nomeAlterar.text!.isEmpty {
            do{
                _ = try db?.run(cliente.insert(nome <- self.nomeAlterar.text!))
                let cliente = Cliente(id: arrayCliente.count+1, nome: self.nomeAlterar.text!)
                arrayCliente.append(cliente)
                self.loadView()
                print("Dados inseridos com sucesso!!!")
            }catch{
                print(errosSQLite.erroNoInserir)
            }
        }
        
        //Ler
        do{
            for clientes in try (db?.prepare(cliente))!{
                print("Id: \(clientes[id]) Nome: \(clientes[nome])")
            }
        }catch{
            print(errosSQLite.erroNoLer)
        }
    }

//    @IBAction func toqueNoAdicionar(_ sender: UITapGestureRecognizer) {
//        tap.isEnabled = true
//        if self.nomeAlterar.text!.isEmpty {
//            let alertController = UIAlertController(title: nil, message:
//                "Digite em novo nome para adicionar alguém!!!", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default,handler: nil))
//            
//            present(alertController, animated: true, completion: nil)
//            
//        }else{
//            tap.isEnabled = false
//        }
//    }
}

