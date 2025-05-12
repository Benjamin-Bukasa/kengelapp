import React, { useEffect, useState } from 'react';
import axios from 'axios';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import jsPDF from 'jspdf';
import 'jspdf-autotable';
import { Eye, Edit, Trash2, Search, Download } from 'lucide-react';

const AdvancedTable = () => {
  const [data, setData] = useState([]);
  const [filteredData, setFilteredData] = useState([]);
  const [searchText, setSearchText] = useState('');
  const [search, setSearch] = useState('');
  const [dateMin, setDateMin] = useState('');
  const [dateMax, setDateMax] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage, setItemsPerPage] = useState(5);
  const [selectedRows, setSelectedRows] = useState([]);
  const [columns, setColumns] = useState({
    name: true,
    email: true,
    phone: true,
    createdAt: true,
  });
  const [sortConfig, setSortConfig] = useState({ key: null, direction: 'ascending' });
  const [exportType, setExportType] = useState('xlsx');

  useEffect(() => {
    axios.get('https://jsonplaceholder.typicode.com/users')
      .then(response => {
        const enhancedData = response.data.map(user => ({
          ...user,
          createdAt: randomDate(new Date(2023, 0, 1), new Date()).toISOString().split('T')[0], // date format YYYY-MM-DD
        }));
        setData(enhancedData);
        setFilteredData(enhancedData);
      })
      .catch(error => console.error(error));
  }, []);

  const randomDate = (start, end) => {
    return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
  };

  const applyFilters = () => {
    let temp = [...data];

    if (searchText.trim() !== '') {
      temp = temp.filter(user =>
        user.name.toLowerCase().includes(searchText.toLowerCase()) ||
        user.email.toLowerCase().includes(searchText.toLowerCase()) ||
        user.phone.toLowerCase().includes(searchText.toLowerCase())
      );
    }

    if (dateMin) {
      temp = temp.filter(user => new Date(user.createdAt) >= new Date(dateMin));
    }
    if (dateMax) {
      temp = temp.filter(user => new Date(user.createdAt) <= new Date(dateMax));
    }

    setFilteredData(temp);
    setCurrentPage(1);
  };

  const handleExport = () => {
    const exportData = getSelectedData().map(user => {
      const obj = {};
      if (columns.name) obj["Nom"] = user.name;
      if (columns.email) obj["Email"] = user.email;
      if (columns.phone) obj["Téléphone"] = user.phone;
      if (columns.createdAt) obj["Date Création"] = user.createdAt;
      return obj;
    });

    if (exportType === 'xlsx') {
      
        const worksheet = XLSX.utils.json_to_sheet(exportData);
        const workbook = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(workbook, worksheet, "Utilisateurs");
        const excelBuffer = XLSX.write(workbook, { bookType: "xlsx", type: "array" });
        const blob = new Blob([excelBuffer], { type: "application/octet-stream" });
        saveAs(blob, "utilisateurs_selection.xlsx");

    } else if (exportType === 'csv') {

        const worksheet = XLSX.utils.json_to_sheet(exportData);
        const csv = XLSX.utils.sheet_to_csv(worksheet);
        const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
        saveAs(blob, "utilisateurs_selection.csv");

    } else if (exportType === 'pdf') {

        const doc = new jsPDF();
        const tableColumn = Object.keys(exportData[0]);
        const tableRows = exportData.map(item => Object.values(item));
        doc.autoTable({
            head: [tableColumn],
            body: tableRows,
        });
        doc.save('utilisateurs_selection.pdf');
    }
  };

  const getSelectedData = () => {
    if (selectedRows.length > 0) {
      return filteredData.filter(user => selectedRows.includes(user.id));
    }
    return filteredData;
  };

  const sortedData = [...filteredData].sort((a, b) => {
    if (sortConfig.key) {
      const aValue = a[sortConfig.key]?.toString().toLowerCase() || '';
      const bValue = b[sortConfig.key]?.toString().toLowerCase() || '';
      if (aValue < bValue) return sortConfig.direction === 'ascending' ? -1 : 1;
      if (aValue > bValue) return sortConfig.direction === 'ascending' ? 1 : -1;
    }
    return 0;
  });

  const displayedData = sortedData.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  const handleSort = (key) => {
    let direction = 'ascending';
    if (sortConfig.key === key && sortConfig.direction === 'ascending') {
      direction = 'descending';
    }
    setSortConfig({ key, direction });
  };

  return (
    <div className="p-4 space-y-4">
      {/* Zone de filtres */}
      <div className="flex flex-wrap gap-4 justify-between">
        <div className="w-1/4 flex justify-between gap-1">
            <input
            type="text"
            placeholder="Rechercher..."
            value={searchText}
            onChange={(e) => setSearchText(e.target.value)}
            className="px-4 py-2 border rounded w-full flex-1 md:w-1/4 outline-none"
            />
            <button
            onClick={applyFilters}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-orange-400 transition-all ease-in-out delay-150"
            >
                <Search />
            </button>
        </div>
        <div className="flex gap-2">
        <input
          type="date"
          value={dateMin}
          onChange={(e) => setDateMin(e.target.value)}
          className="px-2 py-2 border rounded outline-none"
        />
        <input
          type="date"
          value={dateMax}
          onChange={(e) => setDateMax(e.target.value)}
          className="px-2 py-2 border rounded outline-none"
        />
        </div>
        <div className="flex gap-2">
            <select
            value={exportType}
            onChange={(e) => setExportType(e.target.value)}
            className="px-4 py-2 border rounded outline-none"
            >
            <option value="xlsx">Exporter XLSX</option>
            <option value="csv">Exporter CSV</option>
            <option value="pdf">Exporter PDF</option>
            </select>
            <button
            onClick={handleExport}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-orange-400 transition-all ease-in-out delay-150"
            >
                <Download />
            </button>
        </div>
        
        <select
          value={itemsPerPage}
          onChange={(e) => setItemsPerPage(parseInt(e.target.value))}
          className="px-4 py-2 border rounded outline-none"
        >
          <option value="5">5 lignes</option>
          <option value="10">10 lignes</option>
          <option value="20">20 lignes</option>
          <option value="50">50 lignes</option>
        </select>
      </div>

      {/* Sélecteur de colonnes */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
        {Object.keys(columns).map(key => (
          <label key={key} className="flex items-center p-2 border rounded shadow-sm hover:bg-gray-100 space-x-2 text-sm">
            <input
              type="checkbox"
              checked={columns[key]}
              onChange={() => setColumns(prev => ({ ...prev, [key]: !prev[key] }))}
            />
            <span>{key.toUpperCase()}</span>
          </label>
        ))}
      </div>

      {/* Tableau */}
      <div className="overflow-x-auto">
        <table className="min-w-full border border-gray-300 text-sm text-left text-gray-700">
          <thead className="bg-gray-100 text-xs uppercase text-gray-600">
            <tr>
              <th className="px-4 py-2 border">Select</th>
              {columns.name && <th className="px-4 py-2 border cursor-pointer" onClick={() => handleSort('name')}>Nom</th>}
              {columns.email && <th className="px-4 py-2 border cursor-pointer" onClick={() => handleSort('email')}>Email</th>}
              {columns.phone && <th className="px-4 py-2 border cursor-pointer" onClick={() => handleSort('phone')}>Téléphone</th>}
              {columns.createdAt && <th className="px-4 py-2 border cursor-pointer" onClick={() => handleSort('createdAt')}>Date</th>}
              <th className="px-4 py-2 border">Actions</th>
            </tr>
          </thead>
          <tbody>
            {displayedData.map(user => (
              <tr key={user.id} className="hover:bg-blue-100">
                <td className="px-4 py-2 border text-center">
                  <input
                    type="checkbox"
                    checked={selectedRows.includes(user.id)}
                    onChange={() => setSelectedRows(prev =>
                      prev.includes(user.id)
                        ? prev.filter(id => id !== user.id)
                        : [...prev, user.id]
                    )}
                  />
                </td>
                {columns.name && <td className="px-4 py-2 border">{user.name}</td>}
                {columns.email && <td className="px-4 py-2 border">{user.email}</td>}
                {columns.phone && <td className="px-4 py-2 border">{user.phone}</td>}
                {columns.createdAt && <td className="px-4 py-2 border">{user.createdAt}</td>}
                <td className="px-4 py-2 border flex space-x-2">
                  <Eye size={18} className="text-blue-500 hover:text-blue-700 cursor-pointer" />
                  <Edit size={18} className="text-green-500 hover:text-green-700 cursor-pointer" />
                  <Trash2 size={18} className="text-red-500 hover:text-red-700 cursor-pointer" />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex justify-center items-center mt-4 space-x-2">
        <button
          onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
          className="px-3 py-1 bg-gray-300 rounded hover:bg-gray-400"
        >
          Précédent
        </button>
        <span className="text-sm">Page {currentPage} sur {Math.ceil(filteredData.length / itemsPerPage)}</span>
        <button
          onClick={() => setCurrentPage(prev => Math.min(prev + 1, Math.ceil(filteredData.length / itemsPerPage)))}
          className="px-3 py-1 bg-gray-300 rounded hover:bg-gray-400"
        >
          Suivant
        </button>
      </div>
    </div>
  );
};

export default AdvancedTable;
